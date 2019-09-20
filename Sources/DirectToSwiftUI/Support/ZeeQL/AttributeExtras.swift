//
//  AttributeExtras.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import Foundation
import protocol ZeeQL.Attribute

public extension Attribute {
  var isPassword : Bool {
    let lc = name.lowercased()
    return lc.contains("password") || lc.contains("passwd")
  }
}

public extension Attribute {
  // TODO: Check width and such.
  // TODO: Belongs into ZeeQL (and should also be called by AR)
  
  func validateForInsert(_ object: AnyObject?) -> Bool {
    guard let object = object else { return false }
    let nullable = allowsNull ?? true
    if !nullable, KeyValueCoding.value(forKey: name, inObject: object) == nil {
      let isAutoIncrement = self.isAutoIncrement ?? false
      if !isAutoIncrement { return false }
    }
    return true
  }
  func validateForUpdate(_ object: AnyObject?) -> Bool {
    guard let object = object else { return false }
    let nullable = allowsNull ?? true
    if !nullable, KeyValueCoding.value(forKey: name, inObject: object) == nil {
      return false
    }
    return true
  }
}

public extension Relationship {
  
  func validateForInsert(_ object: AnyObject?) -> Bool {
    return validateForUpdate(object)
  }
  
  func validateForUpdate(_ object: AnyObject?) -> Bool {
    guard let object = object else { return false }
    if !isMandatory { return true }
    
    let target = KeyValueCoding.value(forKeyPath: name, inObject: object)
    if target != nil { return true } // relationship is available
    
    // Note: The full object might not be fetched, but we could still have the
    //       relevant foreign key set!

    var hadValidJoin = false
    for join in joins {
      guard let name = join.sourceName ?? join.source?.name else {
        assertionFailure("join w/o name")
        return true // let DB deal w/ it
      }
      
      // technically we would need to check whether the attribute is nullable
      // or not for compound keys (/ and also validate the attribute)
      if KeyValueCoding.value(forKeyPath: name, inObject: object) != nil {
        hadValidJoin = true
        break
      }
    }
    return hadValidJoin
  }
}

fileprivate let ddateFormatter : DateFormatter = {
  let df = DateFormatter()
  df.dateStyle = .medium
  df.timeStyle = .none
  df.doesRelativeDateFormatting = true // today, tomorrow
  return df
}()
fileprivate let timeFormatter : DateFormatter = {
  let df = DateFormatter()
  df.dateStyle = .none
  df.timeStyle = .medium
  df.doesRelativeDateFormatting = true // today, tomorrow
  return df
}()
internal let dateTimeFormatter : DateFormatter = {
  let df = DateFormatter()
  df.dateStyle = .medium
  df.timeStyle = .medium
  df.doesRelativeDateFormatting = true // today, tomorrow
  return df
}()

public extension Attribute {
  
  func dateFormatter() -> DateFormatter {
    guard let externalType = externalType?.uppercased() else {
      return dateTimeFormatter
    }
    
    if externalType.contains("TIMESTAMP") { return dateTimeFormatter }
    if externalType.contains("DATETIME")  { return dateTimeFormatter }
    if externalType.contains("DATE")      { return ddateFormatter    }
    if externalType.contains("TIME")      { return timeFormatter     }
    
    return dateTimeFormatter
  }
  
}

enum D2SAttributeCoercionError: Swift.Error {
  case failedToCoerceFromString(String?, Attribute)
}

public extension Attribute {
  
  func coerceFromString(_ string: String?) throws -> Any? {
    func logError() throws -> Any? {
      throw D2SAttributeCoercionError.failedToCoerceFromString(string, self)
    }
    
    guard let valueType = valueType else { // no type assigned, use as-is
      return string
    }
    
    var trimmed : String? {
      guard let s = string else { return nil }
      let t = s.trimmingCharacters(in: .whitespaces)
      return t.isEmpty ? nil : t
    }
    func coerce<I: FixedWidthInteger>(to type: I.Type) throws -> Any? {
      guard let s = trimmed else { return try logError() }
      guard let i = I(s)    else { return try logError() }
      return i
    }
    func coerceOpt<I: FixedWidthInteger>(to type: I.Type) throws -> Any? {
      guard let s = trimmed else { return nil }
      guard let i = I(s)    else { return try logError() }
      return i
    }
    
    // ☢️ QUICK: LOOK AWAY. Dirty dirty stuff ahead! ☢️
    
    if valueType == String .self { return string }
    if valueType == String?.self {
      guard let s = string else { return try logError() }
      return s
    }
    if valueType == Int.self     { return try coerce   (to: Int.self) }
    if valueType == Int?.self    { return try coerceOpt(to: Int.self) }
    
    if valueType == Date.self {
      guard let s = trimmed else { return try logError() }
      guard let v = dateFormatter().date(from: s) else { return try logError() }
      return v
    }
    if valueType == Date?.self {
      guard let s = trimmed else { return nil }
      guard let v = dateFormatter().date(from: s) else { return try logError() }
      return v
    }
    
    if valueType == Bool.self {
      guard let s = trimmed?.lowercased() else { return false }
      if s.isEmpty { return false }
      if falseStrings.first(where: { s.contains($0)} ) != nil { return false }
      return true
    }
    if valueType == Bool?.self {
      guard let s = trimmed?.lowercased() else { return nil }
      if s.isEmpty { return false }
      if falseStrings.first(where: { s.contains($0)} ) != nil { return false }
      return true
    }

    if valueType == Float.self {
      guard let s = trimmed  else { return try logError() }
      guard let v = Float(s) else { return try logError() }
      return v
    }
    if valueType == Float?.self {
      guard let s = trimmed else { return nil }
      guard let v = Float(s) else { return try logError() }
      return v
    }

    if valueType == Double.self {
      guard let s = trimmed else { return try logError() }
      guard let v = Double(s) else { return try logError() }
      return v
    }
    if valueType == Double?.self {
      guard let s = trimmed else { return nil }
      guard let v = Double(s) else { return try logError() }
      return v
    }

    if valueType == Decimal?.self {
      guard let s = trimmed else { return nil }
      guard let v = Decimal(string: s) else { return try logError() }
      return v
    }

    if valueType == URL.self {
      guard let s = trimmed else { return nil }
      guard let v = URL(string: s) else { return try logError() }
      return v
    }
    if valueType == URL?.self {
      guard let s = trimmed else { return nil }
      guard let v = URL(string: s) else { return try logError() }
      return v
    }
    
    // Data. Hm, well, what would the Data be, UTF8?

    // TODO: all the different Int variants!
    if valueType == UInt.self   { return try coerce   (to: UInt .self) }
    if valueType == UInt?.self  { return try coerceOpt(to: UInt .self) }
    if valueType == Int8.self   { return try coerce   (to: Int8 .self) }
    if valueType == Int8?.self  { return try coerceOpt(to: Int8 .self) }
    if valueType == Int16.self  { return try coerce   (to: Int16.self) }
    if valueType == Int16?.self { return try coerceOpt(to: Int16.self) }
    if valueType == Int32.self  { return try coerce   (to: Int32.self) }
    if valueType == Int32?.self { return try coerceOpt(to: Int32.self) }
    if valueType == Int64.self  { return try coerce   (to: Int64.self) }
    if valueType == Int64?.self { return try coerceOpt(to: Int64.self) }
    
    return try logError()
  }
  
}

fileprivate let falseStrings = [
  "no", "false", "nein", "njet", "nada", "nope"
]
