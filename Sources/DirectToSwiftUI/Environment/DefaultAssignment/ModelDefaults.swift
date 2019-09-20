//
//  D2SModel.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import class    ZeeQL.Model
import protocol ZeeQL.Attribute
import protocol ZeeQL.Relationship

public extension Model {
  var d2s : ModelD2S { return ModelD2S(model: self) }
}
public extension Attribute {
  var d2s : AttributeD2S { return AttributeD2S(attribute: self) }
}
public extension Relationship {
  var d2s : RelationshipD2S { return RelationshipD2S(relationship: self) }
}

public struct ModelD2S {
  let model : Model

  public var isDefault : Bool { D2SKeys.model.defaultValue === model }
  
  public var defaultVisibleEntityNames : [ String ] {
    // Loop through rule system to derive displayName?
    // No, that would be the job of a view (set the entity, query the title)
    return model.entities.map { $0.name }
      .sorted() // TBD: but probably makes sense
  }
}

public struct AttributeD2S {
  let attribute : Attribute
  
  public var isDefault : Bool { attribute is D2SDefaultAttribute }
}

public struct RelationshipD2S {
  let relationship : Relationship
  
  public enum RelationshipType: Hashable {
    case none, toOne, toMany
    
    public var isRelationship: Bool {
      switch self {
        case .none: return false
        case .toOne, .toMany: return true
      }
    }
  }
  
  public var isDefault : Bool { relationship is D2SDefaultRelationship }
  public var type      : RelationshipType {
    if relationship is D2SDefaultRelationship { return .none }
    if relationship.isToMany { return .toMany }
    return .toOne
  }
}
