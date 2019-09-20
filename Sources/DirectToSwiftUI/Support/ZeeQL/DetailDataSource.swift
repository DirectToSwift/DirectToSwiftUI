//
//  DetailDataSource.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import ZeeQL

extension ActiveRecord {
  
  // TODO: Move to ZeeQL
  
  func dataSourceQualifiedByKey(_ key: String)
       -> ActiveDataSource<OActiveRecord>?
  {
    // We could try to extract the proper static type using
    //   CodeRelationshipBase<Target: SwiftObject>
    
    // Hm, this is a little tricky. It is already implemented in ZeeQL itself
    // for relationship _prefetches_. But there doesn't seem to be a way
    // to construct it manually?
    // Specifically it is hard to apply the the joinSemantics properly w/o
    // access to SQL. W/o a reciprocal relationship that is.
    
    guard let relship = entity[relationship: key] else {
      globalD2SLogger.log("attempt to qualify by unknown key:", key, "\n",
                          "  datasource:", self)
      return nil
    }
    guard let entity = relship.destinationEntity else {
      globalD2SLogger.log("can't qualify relship w/o entity:", key, "\n",
                          "  relationship:", relship, "\n",
                          "  datasource:  ", self)
      return nil
    }
    let ds = ActiveDataSource<OActiveRecord>(database: database, entity: entity)
    ds.fetchSpecification = ModelFetchSpecification(
      entity    : entity, // TODO
      qualifier : relship.qualifierInDestinationForSource(self)
    )
    
    return ds
  }
  
}

extension Relationship {
  
  func qualifierInDestinationForSource(_ source: DatabaseObject) -> Qualifier? {
    // FIXME: Still has issues for some setups (FilmActors N:M)
    guard !joins.isEmpty else { return nil }
    
    var qualifiers = [ Qualifier ]()
    qualifiers.reserveCapacity(joins.count)
    
    for join in joins {
      guard let destAttrName = join.destinationName
                            ?? join.destination?.name else {
        globalD2SLogger.error("join has no destination:", join, self)
        return nil
      }
      
      guard let srcAttrName = join.sourceName ?? join.source?.name else {
        globalD2SLogger.error("join has no source:", join, self)
        return nil
      }
      
      let selfValue = source.value(forKey: srcAttrName)
      let destKey   = StringKey(destAttrName)
      
      let q = KeyValueQualifier(destKey, .EqualTo, selfValue)
      qualifiers.append(q)
    }
    
    guard !qualifiers.isEmpty else { return nil }
    if qualifiers.count == 1 { return qualifiers[0] }
    return CompoundQualifier(qualifiers: qualifiers, op: .And)
  }
}


extension ActiveRecord {
  
  func primaryFetchToOneRelationship(_ name: String, force: Bool = false)
         throws
       -> OActiveRecord?
  {
    if !force,
       let target = KeyValueCoding.value(forKeyPath: name,
                                         inObject: self) as? OActiveRecord {
      return target // cached, prefetched
    }
    
    guard let ds = self.dataSourceQualifiedByKey(name) else {
      globalD2SLogger.error("could not build datasource for:", name)
      return nil
    }
    do {
      ds.fetchSpecification = ds.fetchSpecification?.limit(2)
      let results = try ds.fetchObjects()
      guard !results.isEmpty else {
        globalD2SLogger.log("did not find relationship target:", name)
        return nil
      }
      if results.count > 1 {
        globalD2SLogger.warn("more than one record match toOne relship:",
                             name, "\n",
                             "  ds:", ds, "\n",
                             "  Q: ", ds.fetchSpecification?.qualifier)
        assertionFailure("two-one fetch yielded more than one object!")
      }
      return results.first
    }
    catch {
      globalD2SLogger.error(
        "failed to fetch relationship:", name, "\n",
        "  error: ", error, "\n",
        "  object:", self
      )
      throw error
    }
  }
  
}

import class Dispatch.DispatchQueue
import Combine

@available(iOS 13, tvOS 13, OSX 10.15, watchOS 6, *)
public extension OActiveRecord {
  
  func fetchToOneRelationship(_ propertyKey: String,
                              on queue: DispatchQueue = .global())
       -> AnyPublisher<OActiveRecord?, Error>
  {
    
    Future { promise in
      queue.async {
        do {
          // TBD: Why isn't this public? I guess because we are supposed to
          //      set the FS on the datasource.
          let destination = try self.primaryFetchToOneRelationship(propertyKey)
          promise(.success(destination))
        }
        catch {
          promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }
  
}

extension ActiveRecord {
  
  /**
   * Like `addObject(_:toPropertyWithKey:)`, but also push the foreign keys.
   *
   * This is to support AR which stores those in the record itself.
   */
  func wire(destination: ActiveRecord?, to relationship: Relationship) {
    do {
      guard let destination = destination else {
        try takeValue(nil, forKey: relationship.name)
        for join in relationship.joins {
          guard let sourceName = join.source?.name ?? join.sourceName else {
            globalD2SLogger.error("unexpected join:", join, relationship)
            assertionFailure("unexpected join: \(join)")
            continue
          }
          try takeValue(nil, forKey: sourceName)
        }
        return
      }
    
      addObject(destination, toPropertyWithKey: relationship.name)
    
      for join in relationship.joins {
        guard let sourceName = join.source?.name ?? join.sourceName else {
          globalD2SLogger.error("unexpected join:", join, relationship)
          assertionFailure("unexpected join: \(join)")
          continue
        }
        
        if let destName = join.destination?.name ?? join.destinationName {
          try takeValue(destination.value(forKey: destName), forKey: sourceName)
        }
        else {
          try takeValue(nil, forKey: sourceName)
        }
      }
    }
    catch {
      globalD2SLogger.error("could not apply value for:", relationship,
                            "\n  in:", self)
    }
  }
}

/**
 * This is similar to a GlobalID, but it can match any properties in the
 * destination.
 */
struct JoinTargetID: Hashable {
  // TBD: calc hash once

  let values : [ Any? ]

  init?(source: OActiveRecord, relationship: Relationship) {
    // TBD: if the source has the relationship _object_ assigned,
    //      rather grab the values of the dest object? (and maybe
    //      match them up and report inconsistencies).
    if relationship.joins.isEmpty { return nil }
    
    var hadNonNil = false
    var values = [ Any? ]()
    values.reserveCapacity(relationship.joins.count)
    for join in relationship.joins {
      guard let name  = (join.source?.name ?? join.sourceName),
            let value = source.value(forKey: name) else {
        values.append(nil)
              continue
      }
      values.append(value)
      if !hadNonNil { hadNonNil = true }
    }
    if !hadNonNil { return nil }
    self.values = values
  }
  init(destination: OActiveRecord, relationship: Relationship) {
    values = relationship.joins.map { join in
      (join.destination?.name ?? join.destinationName)
        .flatMap { name in destination.value(forKey: name) }
    }
  }
  
  static func == (lhs: Self, rhs: Self) -> Bool {
    guard lhs.values.count == rhs.values.count else { return false }
    for i in lhs.values.indices {
      // Yes, I know.
      if !eq(lhs.values[i], rhs.values[i]) { return false }
    }
    return true
  }
  
  func hash(into hasher: inout Hasher) { // lame
    guard let f = values.first else { return }
    if let i = f as? Int    { return i.hash(into: &hasher) }
    if let i = f as? Int64  { return i.hash(into: &hasher) }
    if let i = f as? String { return i.hash(into: &hasher) }
    return String(describing: f).hash(into: &hasher)
  }
  
}
