//
//  ZeeQLExtras.swift
//  ApacheExpressAdmin
//
//  Copyright © 2017-2019 ZeeZide GmbH. All rights reserved.
//

import protocol ZeeQL.Entity

public extension Entity {

  /**
   * If name/extname differ, returns "Entity (Table)", if they are the same
   * just "Entity".
   */
  var displayNameWithExternalName : String {
    if let extName = self.externalName, !extName.isEmpty {
      if extName != self.name {
        return "\(self.name) (\(extName))"
      }
    }
    return self.name
  }
}

public extension Entity {
  
  func lookupUserDatabaseProperties()
       -> ( login: Attribute, password: Attribute )?
  {
    let op = self[attribute: "password"]
          ?? self[attribute: "passwd"]
          ?? self[attribute: "pwd"]
          ?? self[attribute: "credentials"]
          ?? self[attribute: "creds"]
    guard let pwdAttr = op else { return nil }
    
    let ou = self[attribute: "login"]
          ?? self[attribute: "username"]
          ?? self[attribute: "user"]
          ?? self[attribute: "email"]
    guard let userAttr = ou else { return nil }

    return ( userAttr, pwdAttr )
  }
  
}

extension Entity {
  
  var singleIntegerPrimaryKeyAttribute : Attribute? {
    guard let pkeys = primaryKeyAttributeNames, pkeys.count == 1
     else { return nil }

    guard let attribute = self[attribute: pkeys[0]] else { return nil }
    return attribute.isIntegerAttribute ? attribute : nil
  }
}

extension Entity {
  
  /// Returns all attributes which have String or String? as the value type.
  var stringAttributeNames : [ String ] {
    return attributes.compactMap { $0.isStringAttribute ? $0.name : nil }
  }
  
  /// Returns all attributes which have Int or Int? as the value type.
  var numberAttributeNames : [ String ] {
    return attributes.compactMap { $0.isIntegerAttribute ? $0.name : nil }
  }
  
  func qualifierForQueryString(_ qs: String) -> Qualifier? {
    // Also (kinda replaced by): QueryStringParser
    //
    // TODO: detect numbers? booleans? what else makes sense? :-)
    // we could also do server-side conversion (e.g. int to string, and rev)
    // TODO: split on space
    //       - well, parse and also support "Hello World"
    // TODO: need a proper tokenizer
    //       => name:He* 10111 -skyrix +addresses.city:Magdeburg
    // TODO: show message unless cookie is set with instructions (using Semantic
    //       Nag attached to cookie)
    let isNumber = Int(qs)
    var q        : Qualifier? = nil
    
    let strattrs = stringAttributeNames
    if !strattrs.isEmpty {
      let pat = qs.contains("*") ? qs : ("*" + qs + "*")
      var map = [ String : String ]()
      for name in strattrs {
        map[name] = pat
      }
      q = or(q, qualifierToMatchAnyValue(
        map, pat.isMixedCase ? .Like : .CaseInsensitiveLike)
      )
    }
    
    if let numberValue = isNumber {
      var map = [ String : Int ]()
      for name in numberAttributeNames {
        map[name] = numberValue
      }
      q = or(q, qualifierToMatchAnyValue(map, .EqualTo))
    }
    
    return q
  }
}


// MARK: - Support

import struct Foundation.Decimal

fileprivate extension AttributeValue {
  // FIXME: Move the 'type' to ZeeQL.AttributeValue itself.
  
  static var isStringAttribute : Bool {
    return self == String.self || self == Optional<String>.self
  }
  
  static var isIntegerAttribute : Bool {
    // TODO: Can we at least `switch` over self?
    // ... so many dead kittens.
    if self == Int.self    || self == Optional<Int>.self    { return true }
    if self == Int8.self   || self == Optional<Int8>.self   { return true }
    if self == Int16.self  || self == Optional<Int16>.self  { return true }
    if self == Int32.self  || self == Optional<Int32>.self  { return true }
    if self == Int64.self  || self == Optional<Int64>.self  { return true }
    if self == UInt.self   || self == Optional<UInt>.self   { return true }
    if self == UInt8.self  || self == Optional<UInt8>.self  { return true }
    if self == UInt16.self || self == Optional<UInt16>.self { return true }
    if self == UInt32.self || self == Optional<UInt32>.self { return true }
    if self == UInt64.self || self == Optional<UInt64>.self { return true }
    if self == Decimal.self { return true }
    return false
  }
}

// Those do not kick in because `AttributeValue` is type erased

fileprivate extension AttributeValue where Self : StringProtocol {
  static var isStringAttribute : Bool { return true }
}
fileprivate extension AttributeValue where Self : FixedWidthInteger {
  static var isIntegerAttribute : Bool { return true }
}
fileprivate extension Optional where Wrapped : StringProtocol {
  static var isStringAttribute : Bool { return true }
}
fileprivate extension Optional where Wrapped : FixedWidthInteger {
  static var isIntegerAttribute : Bool { return true }
}


extension Attribute {
  // TBD: check externalType if no valueType is present
  
  var isStringAttribute : Bool {
    guard let t = valueType else {
      // this is kinda OK, can happen, e.g. in dvdrental for DATE(4)
      // (which should be a DateComponents)
      globalD2SLogger.trace("attribute has no value type?:", self)
      return false
    }
    return t.isStringAttribute
  }
  
  var isIntegerAttribute : Bool {
    guard let t = valueType else {
      globalD2SLogger.trace("attribute has no value type?:", self)
      return false
    }
    return t.isIntegerAttribute
  }
  
}


extension Entity {
  
  /**
   * Extract prefetch pathes from keypath property names. For example:
   *
   *   [ film.title, film.rating ]
   *
   * Becomes
   *
   *   [ film ]
   *
   * Because that is the relationship that needs to be prefetched to resolve
   * the property keys.
   */
  func prefetchPathesForPropertyKeys<S: Sequence>(_ propertyKeys: S)
    -> [ String ]? where S.Element == String
  {
    var pathes = Set<String>()
    for propertyKey in propertyKeys {
      insertPrefetchPathesForPropertyKey(propertyKey, into: &pathes)
    }
    if pathes.isEmpty { return nil }
    return Array(pathes)
  }

  private func insertPrefetchPathesForPropertyKey(_ propertyKey: String,
                                                  into set: inout Set<String>)
  {
    if self[attribute: propertyKey] != nil { return }
    
    if self[relationship: propertyKey] != nil {
      // This is a little weird, it means that the user directly chose a full
      // object to display, like "film"
      set.insert(propertyKey)
      return
    }
    
    guard let r = propertyKey.range(of: ".") else { return }
    let relationshipName = String(propertyKey[..<r.lowerBound])
    
    guard let relationship = self[relationship: relationshipName] else {
      return
    }
    guard let destinationEntity = relationship.destinationEntity else {
      globalD2SLogger.log("relationship w/o destination:", relationship)
      return
    }
    
    let subKey = String(propertyKey[r.upperBound...])
    var targetPathes = Set<String>()
    destinationEntity
      .insertPrefetchPathesForPropertyKey(subKey, into: &targetPathes)
    guard !targetPathes.isEmpty else {
      // that is fine, it might be just `address.phone` for example. In this
      // case we still want `address`.
      set.insert(relationshipName)
      return
    }
    
    for path in targetPathes {
      set.insert(relationshipName + "." + path)
    }
  }
  
}
