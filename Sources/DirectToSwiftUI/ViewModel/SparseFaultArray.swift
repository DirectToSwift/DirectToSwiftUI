//
//  SparseFaultArray.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import ZeeQL

/**
 * A helper structure to represent an array of faults, w/o allocating slots
 * for all of them.
 *
 * It also serves as an object cache.
 *
 * The struct conforms to `RandomAccessCollection` so that it can be used as
 * a collection serving SwiftUI `List` and `ForEach` views.
 * Currently it has, however, slightly less performance :-)
 */
public struct SparseFaultArray<Object: AnyObject, Resolver: D2SFaultResolver> {
  // It is not really a sparse array, but more like a sequentially growing one.
  // This could be made much more clever (e.g. it could also throw away objects)
  
  public typealias Element = D2SFault<Object, Resolver>
  public typealias Index   = Int

  // The total count of the collection.
  public private(set) var count = 0
  
  // Objects which got fetched already.
  private var objects      = [ GlobalID : Object ]() // TBD: use NSCache?
  
  // The known GIDs (might not be fetched yet!) in the order of this collection.
  private var knownObjects = [ GlobalID? ]()
  
  // Used by fault objects to trigger a fetch.
  // var, because Swift.
  private unowned var resolver : Resolver?
    
  mutating func assignResolver(_ resolver: Resolver) {
    self.resolver = resolver
  }
  
  public mutating func reset() {
    self.count = 0
    self.objects     .removeAll()
    self.knownObjects.removeAll()
  }
    
  public mutating func clearOrderAndApplyNewCount(_ count: Int) {
    self.count = count
    self.knownObjects.removeAll()
  }
  
  fileprivate mutating func ensurePosition(_ position: Int) {
    assert(position < count)
    if position < knownObjects.count { return }
    knownObjects.reserveCapacity(position + 1)
    for _ in knownObjects.count...position {
      knownObjects.append(.none)
    }
    assert(knownObjects.count <= count)
    assert(knownObjects.count > position)
  }
  
  @inline(__always)
  fileprivate func makeGlobalID(for index: Int) -> GlobalID {
    IndexGlobalID.make(index)
  }
  @inline(__always)
  fileprivate func makeFault(for index: Int) -> Element {
    return D2SFault(makeGlobalID(for: index), resolver!)
  }
  
  public subscript(globalID: GlobalID) -> Object? {
    return objects[globalID]
  }
  
  public func firstAvailableObject(where match: ( Object ) -> Bool) -> Object? {
    objects.values.first(where: match)
  }
}

extension SparseFaultArray: RandomAccessCollection {
  
  @inlinable public var  startIndex : Int { return 0 }
  @inlinable public var  endIndex   : Int { startIndex + count }
  @inlinable public func index(after i: Index) -> Index { i + 1 }

  public subscript(position: Int) -> Element {
    set {
      ensurePosition(position)
      switch newValue {
        case .object(let gid, let object):
          objects[gid] = object
          knownObjects[position] = gid
        case .fault(let gid, _):
          // TBD: we could check the gid type here, but lets assume the user
          // knows what he is doing
          knownObjects[position] = gid
      }
    }
    get {
      if position >= knownObjects.count { // sparse synthesize a fake fault
        return makeFault(for: position)
      }
      
      // Yes, this is not O(1) ;-)
      guard let gid = knownObjects[position] else {
        return makeFault(for: position)
      }
      
      if let object = objects[gid] { return .object(gid, object) }
      return D2SFault(gid, resolver!)
    }
  }
}

extension SparseFaultArray {
  
  mutating func append(_ fault: Element) { // TODO: remove me
    let pos = count
    count += 1
    ensurePosition(pos)
    self[pos] = fault // hmmm?
    if case .object(let gid, let object) = fault {
      objects[gid] = object
    }
  }
}

internal final class IndexGlobalID : GlobalID {
  
  private static let sharedIndexGIDs : [ IndexGlobalID ] = { // prealloc some
    (0...50).map(IndexGlobalID.init)
  }()
  
  // TBD: we _could_ scope by something.
  public let index : Int
  
  @inlinable
  public static func make(_ index: Int) -> IndexGlobalID {
    return index < IndexGlobalID.sharedIndexGIDs.count
      ? IndexGlobalID.sharedIndexGIDs[index]
      : IndexGlobalID(index)
  }
  
  private init(_ index: Int) {
    self.index = index
  }
  
  override func isEqual(to object: Any?) -> Bool {
    guard let gid = object as? IndexGlobalID else { return false }
    return gid == self
  }
  
  override func hash(into hasher: inout Hasher) {
    index.hash(into: &hasher)
  }
  
  public static func ==(lhs: IndexGlobalID, rhs: IndexGlobalID) -> Bool {
    return lhs.index == rhs.index
  }
}
