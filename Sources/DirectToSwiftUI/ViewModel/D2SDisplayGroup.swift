//
//  D2SDisplayGroup.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import Combine
import SwiftUI
import ZeeQL

/**
 * Simple notification delegate.
 */
public protocol D2SObjectContainer {
  
}

/**
 * This handles the fetches and results for a single fetch specification.
 *
 * Properties:
 * - error
 * - results (a collection of D2SFault values)
 * - queryString (search for a string, via `qualifierForQueryString`)
 * - sortAttribute
 */
public final class D2SDisplayGroup<Object: OActiveRecord>
                   : ObservableObject, D2SFaultResolver, D2SObjectContainer
{
  
  @Published var error   : Swift.Error?
  @Published var results = SparseFaultArray<Object, D2SDisplayGroup<Object>>()
  
  @Published var queryString = "" {
    didSet {
      guard oldValue != queryString else { return }
      let qs = dataSource.entity?.qualifierForQueryString(queryString)
      let q  = and(qs, auxiliaryQualifier)
      guard !q.isEqual(to: fetchSpecification.qualifier) else { return }
      fetchSpecification.qualifier = q
    }
  }
  @Published var sortAttribute : Attribute? = nil {
    didSet {
      guard oldValue !== sortAttribute else { return }
      if let newValue = sortAttribute {
        self.fetchSpecification.sortOrderings = [
          SortOrdering(key: newValue.name, selector: .CompareAscending)
        ]
      }
      else {
        self.fetchSpecification.sortOrderings =
          dataSource.entity?.d2s.defaultSortOrderings ?? []
      }
    }
  }
  
  internal let dataSource         : ActiveDataSource<Object>
  private  let batchCount         : Int
  
  private  var auxiliaryQualifier : Qualifier? = nil
  private  var fetchSpecification : ModelFetchSpecification {
    didSet { setNeedsRefetch() }
  }
  
  private func setNeedsRefetch() { needsRefetch.send(fetchSpecification) }
  private var needsRefetch = PassthroughSubject<FetchSpecification, Never>()
    // Not using @Published because we want a _didset_
  
  public init(dataSource: ActiveDataSource<Object>,
              auxiliaryQualifier: Qualifier? = nil,
              displayPropertyKeys: [ String ]? = nil,
              batchCount: Int = 20)
  {
    // Note: We always fetch full objects, for the list we could also just
    //       select the displayPropertyKeys, but then we'd have to fetch the
    //       full object for editing. Which might make sense :-)
    self.batchCount         = batchCount
    self.dataSource         = dataSource
    self.auxiliaryQualifier = auxiliaryQualifier
    self.fetchSpecification = buildInitialFetchSpec(for: dataSource,
                                auxiliaryQualifier: auxiliaryQualifier)
    if let keys = displayPropertyKeys, let entity = dataSource.entity {
      self.fetchSpecification.prefetchingRelationshipKeyPathes =
        entity.prefetchPathesForPropertyKeys(keys)
    }
    
    results.assignResolver(self)
    
    _ = needsRefetch
      .debounce(for: 0.5, scheduler: RunLoop.main)
      .sink { [weak self] newValue in
        self?.fetchCount(newValue)
      }
    
    self.fetchCount(fetchSpecification)
  }
  
  
  // MARK: - Reloading
  
  public func reload() {
    // TBD: somehow cancel running fetches
    activeQueries.removeAll()
    results.reset()
    self.fetchCount(fetchSpecification)
  }
  
  
  // MARK: - Errors
  
  private func handleError(_ error: Swift.Error) {
    assert(_dispatchPreconditionTest(.onQueue(.main)))
    self.error = error
  }
  
  
  // MARK: - Fetching Counts
  
  private func integrateCount(_ count: Int) {
    assert(_dispatchPreconditionTest(.onQueue(.main)))
    
    #if false // nope, a fetch count means we rebuild!
      if count == results.count { return } // all good already
    #endif
    globalD2SLogger.info("refresh with count:", count)
    
    // TBD: we could decide to fetch all pkeys based on the count?
    //      well, this affects the type. Only if the single primary key
    //      is an Int (because then it would be compatible with the Index)?
    
    // When the count changes, it always implies that the whole set has changed!
    // E.g. an element in between could have changed!
    // (this is why paging by index is quite generally not a great idea :-) )
    // Note: We keep the fetched GIDs!
    // FIXME: decouple this.
    results.clearOrderAndApplyNewCount(count)
  }
  
  private func fetchCount(_ fetchSpecification: FetchSpecification) {
    let fs = fetchSpecification // has to be done, can't use inside fetchCount?
    _ = dataSource.fetchCount(fs, on: D2SFetchQueue)
      .receive(on: RunLoop.main)
      .catch { ( error : Swift.Error ) -> Just<Int> in
        self.handleError(error)
        return Just(0)
      }
      .sink(receiveValue: self.integrateCount)
  }
  
  
  // MARK: - Fetching Values
  
  // TBD: rewrite this using Combine :-)
  
  private func isAlreadyFetching(_ i: Int) -> Bool {
    return activeQueries.contains { $0.range.contains(i) }
  }
  
  private func integrateResults(_ results: [ Object ], for range: Range<Int>) {
    // TBD: Avoid continuous change notifications by not doing in place
    //      array modifications. Contra: copies each time.
    assert(_dispatchPreconditionTest(.onQueue(.main)))
    
    // FIXME: if we get less, show an error!
    if results.count != range.count {
      // TODO:
      // There have been less than we thought. We need to refetch everything
      // as something affected the count.
      globalD2SLogger.error("count mismatch, expected:", range.count,
                            "returned:", results.count)
      assert(results.count == range.count,
             "count mismatch, concurrent edit (valid but not implemented :-))")
    }
    
    var newResults = self.results
    for ( i, result ) in results.enumerated() {
      let targetIndex = i + range.lowerBound
      assert(newResults.count > targetIndex)
      
      guard let gid = result.globalID else {
        globalD2SLogger.error("got a record w/o a globalID?:", result)
        assertionFailure("record w/o GID")
        continue
      }
      
      if newResults.count > targetIndex {
        newResults[targetIndex] = .object(gid, result)
      }
      else {
        newResults.append(.object(gid, result))
      }
    }
    
    self.results = newResults
  }
  
  private struct Query: Equatable {
    let range : Range<Int>
  }
  private var activeQueries = [ Query ]()
  
  private func fetchRangeForIndex(_ index: Int) -> Range<Int> {
    let batchIndex      = index / batchCount
    let batchStartIndex = batchIndex * batchCount
    
    let endIndex = results.index(batchStartIndex, offsetBy: batchCount,
                                 limitedBy: results.endIndex)
                ?? results.endIndex
    
    return batchStartIndex..<endIndex
  }
  
  private func finishedBatch(_ query: Query) {
    activeQueries.removeAll(where: { $0 == query })
  }
  
  public func resolveFaultWithID(_ gid: GlobalID) {
    // Yeah, we are just prepping things for the real imp using regular GIDs
    if let indexGID = gid as? IndexGlobalID {
      return resolveFault(at: indexGID.index)
    }
    
    globalD2SLogger.error("TODO: resolve fault w/ GID:", gid)
  }
  
  public func resolveFault(at index: Int) {
    assert(_dispatchPreconditionTest(.onQueue(.main)))
    
    guard case .fault = results[index] else { return } // already fetched
    guard !isAlreadyFetching(index)    else { return }

    let dataSource = self.dataSource
    let fetchRange = fetchRangeForIndex(index)
    
    // TODO: add .range operator! (with closed, open, all!)
    let entity = fetchSpecification.entity ?? dataSource.entity
    let fs     = fetchSpecification.range(fetchRange)
    assert(fs.sortOrderings != nil && !(fs.sortOrderings?.isEmpty ?? true))
    
    let query = Query(range: fetchRange)
    activeQueries.append(query) // keep it alive
    
    _ = dataSource.fetchGlobalIDs(fs, on: D2SFetchQueue)
      .receive(on: RunLoop.main)
      .flatMap { ( globalIDs ) -> AnyPublisher<[ Object ], Error> in
        var missingGIDs = Set<GlobalID>()
        var gidToObject = [ GlobalID : Object ]()
        for gid in globalIDs {
          if let object = self.results[gid] { gidToObject[gid] = object }
          else { missingGIDs.insert(gid) }
        }
        
        if missingGIDs.isEmpty {
          let objects = globalIDs.compactMap { gidToObject[$0] }
          return Just(objects)
            .setFailureType(to: Swift.Error.self)
            .eraseToAnyPublisher()
        }
        
        var objectFS = self.fetchSpecification
        objectFS.qualifier =
          missingGIDs.map({ entity!.qualifierForGlobalID($0) }).compactingOr()
        return dataSource.fetchObjects(objectFS, on: D2SFetchQueue)
          .collect() // avoid dispatching each result via GCD
          .map { fetchedObjects in
            for object in fetchedObjects {
              guard let gid = object.globalID else { continue }
              gidToObject[gid] = object
            }
            return globalIDs.compactMap { gidToObject[$0] }
          }
          .eraseToAnyPublisher()
      }
      .receive(on: RunLoop.main)
      .catch { ( error: Swift.Error ) -> AnyPublisher<[ Object ], Never> in
        self.handleError(error)
        return Just([ Object ]()).eraseToAnyPublisher()
      }
      .sink(receiveCompletion: { _ in self.finishedBatch(query) }) { objects in
        self.integrateResults(objects, for: fetchRange)
      }
  }

}

extension FetchSpecification {
  func range(_ range: Range<Int>) -> FetchSpecification {
    self.offset(range.lowerBound).limit(range.count)
  }
}

internal let D2SFetchQueue = DispatchQueue(label: "de.zeezide.d2s.fetchqueue")


fileprivate func buildInitialFetchSpec<Object: ActiveRecordType>
                   (for     dataSource : ActiveDataSource<Object>,
                    auxiliaryQualifier : Qualifier?)
                 -> ModelFetchSpecification
{
  // all cases, kinda non-sense here
  var fs : ModelFetchSpecification = {
    if let fs = dataSource.fetchSpecification {
      return ModelFetchSpecification(fetchSpecification: fs)
    }
    if let entity = dataSource.entity {
      return ModelFetchSpecification(entity: entity)
    }
    if let entityName = dataSource.entityName {
      return ModelFetchSpecification(entityName: entityName)
    }
    return ModelFetchSpecification()
  }()
  
  // We NEED a sort ordering (unless we prefetch all IDs)
  if (fs.sortOrderings?.count ?? 0) == 0 {
    fs.sortOrderings = dataSource.entity?.d2s.defaultSortOrderings ?? []
  }
  assert(fs.sortOrderings != nil && !(fs.sortOrderings?.isEmpty ?? true))
  
  if let aux = auxiliaryQualifier {
    fs.qualifier = aux.and(fs.qualifier)
  }
  
  return fs
}
