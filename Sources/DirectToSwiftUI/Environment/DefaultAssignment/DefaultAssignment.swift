//
//  D2SDefaultAssignment.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUIRules

// A test whether `D2SDefaultAssignment` makes sense.

public enum D2SDefaultAssignments {
  // Namespace for assignments. Needs the `s` because we can't use the generic
  // class in a convenient way.
}

public extension D2SDefaultAssignments {
  // Note: Why can't we access he ruleContext values using KP wrappers?
  //       Because we get it as `DynamicEnvironmentValues`.
  
  typealias A = D2SDefaultAssignment
  
  static var model: A<D2SKeys.model> {
    .init { ruleContext in
      // Hm, this recursion won't fly:
      // \.model.d2s.isDefault == true => \.model <= \.database.model // '!'
      guard let model = ruleContext[D2SKeys.database.self].model else {
        return D2SKeys.model.defaultValue
      }
      return model
    }
  }
  
  static var attribute: A<D2SKeys.attribute> {
    .init { ruleContext in
      let entity      = ruleContext[D2SKeys.entity.self]
      let propertyKey = ruleContext[D2SKeys.propertyKey.self]
      return entity[attribute: propertyKey]
          ?? D2SKeys.attribute.defaultValue
    }
  }
  static var relationship: A<D2SKeys.relationship> {
    .init { ruleContext in
      let entity      = ruleContext[D2SKeys.entity.self]
      let propertyKey = ruleContext[D2SKeys.propertyKey.self]
      return entity[relationship: propertyKey]
          ?? D2SKeys.relationship.defaultValue
    }
  }
  
  static var isEntityReadOnly: A<D2SKeys.isEntityReadOnly> {
    .init { ruleContext in
      let entity     = ruleContext[D2SKeys.entity.self]
      let roEntities = ruleContext[D2SKeys.readOnlyEntityNames.self]
      return roEntities.contains(entity.name)
    }
  }
  static var isObjectEditable: A<D2SKeys.isObjectEditable> {
    .init { ruleContext in !ruleContext[D2SKeys.isEntityReadOnly.self] }
  }
  static var isObjectDeletable: A<D2SKeys.isObjectDeletable> {
    .init { ruleContext in ruleContext[D2SKeys.isObjectEditable.self] }
  }

  static var propertyValue: A<D2SKeys.propertyValue> {
    .init { ruleContext in
      let object      = ruleContext[D2SKeys.object.self]
      let propertyKey = ruleContext[D2SKeys.propertyKey.self]
      return KeyValueCoding.valueForKeyPath(propertyKey, inObject: object)
    }
  }

  static var loginEntity: A<D2SKeys.entity> {
    .init { ruleContext in
      let model = ruleContext[D2SKeys.model.self]
      return model.lookupUserDatabaseEntity() ?? D2SKeys.entity.defaultValue
    }
  }
}


// MARK: - D2SDefaultAssignment

public struct D2SDefaultAssignment<K: DynamicEnvironmentKey>: RuleLiteral {
  // So the advantage here is that we can use the assignment in a rule model,
  // like `true <= D2SDefaultAssignments.relationship`

  let action : ( DynamicEnvironmentValues ) -> K.Value
  
  public init(action : @escaping ( DynamicEnvironmentValues ) -> K.Value) {
    self.action = action
  }
  
  public func value(in context: DynamicEnvironmentValues) -> K.Value {
    return action(context)
  }
}

extension D2SDefaultAssignment: RuleCandidate {
    
  public func isCandidateForKey<K2: DynamicEnvironmentKey>(_ key: K2.Type)
              -> Bool
  {
    return K.self == K2.self
  }
  
  public var candidateKeyType: ObjectIdentifier { ObjectIdentifier(K.self) }
}

extension D2SDefaultAssignment: RuleAction {
  
  public func fireInContext(_ context: RuleContext) -> Any? {
    return value(in: context)
  }
}
