//
//  D2SEntity.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import protocol ZeeQL.Entity

public extension Entity {
  var d2s : EntityD2S { return EntityD2S(entity: self) }
}

public struct EntityD2S {
  let entity : Entity
}

public extension EntityD2S {
  
  var isDefault    : Bool { entity is D2SDefaultEntity }

  var defaultTitle : String { return entity.name }

  var defaultSortOrderings : [ SortOrdering ] {
    if let pkeys = entity.primaryKeyAttributeNames, !pkeys.isEmpty {
      return pkeys.map { pkey in
        SortOrdering(key: pkey, selector: .CompareAscending)
      }
    }
    
    guard let firstAttribute = entity.attributes.first else { return [] }
    return [SortOrdering(key: firstAttribute.name, selector: .CompareAscending)]
  }
  
  /**
   * This first looks at the `classPropertyNames`. If set, it filters out the
   * INT foreign keys and returns them.
   *
   * If `classPropertyNames` is not set, returns attributes + relationships,
   * while also filterting the attributes for INT foreign keys.
   */
  var defaultAttributeAndRelationshipPropertyKeys : [ String ] {
    let fkeys = intForeignKeys
    
    // Note: It is a speciality of AR that we keep the IDs as class properties.
    //       That would not be the case for real, managed, EOs.
    // Here we want to keep the primary key for display, but drop all the
    // keys of the relationships.
    if let names = entity.classPropertyNames?.filter({ !fkeys.contains($0) }) {
      return names
    }
    
    return entity.attributes   .map { $0.name }
                               .filter { !fkeys.contains($0) }
         + entity.relationships.map { $0.name }
  }
  
  var defaultAttributeAndToOnePropertyKeys : [ String ] {
    var propertyKeys = entity.attributes.map { $0.name }
    
    for rs in entity.relationships {
      for fkey in rs.joins.compactMap({ $0.sourceName }) {
        propertyKeys.removeAll(where: { $0 == fkey })
      }
      if !rs.isToMany {
        propertyKeys.append(rs.name)
      }
    }
    
    return propertyKeys
  }

  private func collectSpecialAttributeNames() -> Set<String> {
    var excluded = Set<String>()
    excluded.reserveCapacity(
      entity.relationships.count + (entity.primaryKeyAttributeNames?.count ?? 0)
    )
    
    // exclude all primary keys (TBD: restrict to Int?)
    if let pkeys = entity.primaryKeyAttributeNames {
      excluded.formUnion(pkeys)
    }
    excluded.formUnion(intForeignKeys)
    return excluded
  }
  
  var defaultDisplayPropertyKeys : [ String ] {
    // Note: We do not sort but assume proper ordering
    let excluded = collectSpecialAttributeNames()
    
    return entity.attributes.map { $0.name }.filter {
      !excluded.contains($0)
    }
  }
  
  var defaultSortPropertyKeys : [ String ] {
    let fkeys = intForeignKeys
    return entity.attributes.filter({ !fkeys.contains($0.name) })
                            .map { $0.name }
  }
  
  private var intForeignKeys: Set<String> {
    guard !entity.relationships.isEmpty else { return Set() }
    var excluded = Set<String>()
    excluded.reserveCapacity(entity.relationships.count)
    
    for relship in entity.relationships {
      for join in relship.joins {
        if let source = join.source {
          if source.valueType == Int.self {
            excluded.insert(source.name)
          }
        }
      }
    }
    return excluded
  }
}
