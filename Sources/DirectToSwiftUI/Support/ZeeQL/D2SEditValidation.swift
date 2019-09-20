//
//  D2SEditValidation.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import protocol ZeeQL.Attribute
import class    ZeeQLCombine.OActiveRecord

public protocol D2SAttributeValidator {
  
  associatedtype Object : OActiveRecord
  
  var attribute : Attribute { get }
  var object    : Object    { get }
 
  var isValid   : Bool      { get }
}

public extension D2SAttributeValidator {

  var isValid : Bool {
    return object.isNew
      ? attribute.validateForInsert(object)
      : attribute.validateForUpdate(object)
  }
}


public protocol D2SRelationshipValidator {
  
  associatedtype Object : OActiveRecord
  
  var relationship : Relationship { get }
  var object       : Object       { get }
 
  var isValid      : Bool         { get }
}

public extension D2SRelationshipValidator {

  var isValid : Bool {
    return object.isNew
      ? relationship.validateForInsert(object)
      : relationship.validateForUpdate(object)
  }
}
