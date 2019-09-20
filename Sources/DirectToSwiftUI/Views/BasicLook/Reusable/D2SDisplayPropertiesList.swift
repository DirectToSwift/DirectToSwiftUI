//
//  D2SDisplayPropertiesList.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * Shows a `List` w/ the `displayPropertyKeys` of the object.
 *
 * Supports `hideEmptyProperty`.
 */
public struct D2SDisplayPropertiesList: View {

  @Environment(\.entity)              private var entity
  @Environment(\.object)              private var object
  @Environment(\.displayPropertyKeys) private var displayPropertyKeys
  @Environment(\.hideEmptyProperty)   private var hideEmptyProperty
  
  public init() {}

  typealias PropertyType = RelationshipD2S.RelationshipType
  
  private var propertiesToDisplay: [ String ] {
    if !hideEmptyProperty { return displayPropertyKeys }
        
    return displayPropertyKeys.filter { propertyKey in
      if propertyType(propertyKey).isRelationship { return true }
      
      guard let value =
        KeyValueCoding.value(forKeyPath: propertyKey, inObject: object) else {
          return false
      }
      if let s = value as? String, s.isEmpty { return false }
      return true
    }
  }
  
  private func propertyType(_ propertyKey: String) -> PropertyType {
    entity[relationship: propertyKey]?.d2s.type ?? .none
  }
  
  public var body: some View {
    List(propertiesToDisplay, id: \String.self) { propertyKey in
      PropertySwitch()
        .environment(\.propertyKey, propertyKey)
    }
  }

  private struct PropertySwitch: View {
    @Environment(\.rowComponent) var body
  }
}
