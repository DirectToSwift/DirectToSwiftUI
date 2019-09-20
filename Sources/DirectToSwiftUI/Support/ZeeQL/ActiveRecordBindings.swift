//
//  ActiveRecordBindings.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import ZeeQL

extension ActiveRecord: Identifiable {
  
  // TODO: use the pkey/GID instead. This uses the ObjectIdentifier.
  
  public enum ID: Hashable {
    case globalID(GlobalID)
    case identity(ObjectIdentifier)
  }

  public var id: ID {
    if let globalID = self.globalID { return .globalID(globalID) }
    else { return .identity(ObjectIdentifier(self)) }
  }
}

public extension ActiveRecord {
  // Bindings why try to do type coercion
  // TODO: maybe even do this for any bindings!
  
  func stringBinding(_ keyPath: String) -> Binding<String> {
    return Binding(get: { self.stringValue(for: keyPath) }) { s in
      self.takeStringValue(s, forKeyPath: keyPath)
    }
  }

  func boolBinding(_ keyPath: String) -> Binding<Bool> {
    return Binding(get: { self.boolValue(for: keyPath) ?? false }) { flag in
      self.takeBoolValue(flag, forKeyPath: keyPath)
    }
  }

  func dateBinding(_ keyPath: String) -> Binding<Date> {
    return Binding(get: {
      guard let date = self.dateValue(for: keyPath) else {
        globalD2SLogger.warn("could not get date value for key:", keyPath)
        return Date()
      }
      return date
    })
    { s in
      self.takeDateValue(s, forKeyPath: keyPath)
    }
  }

}

internal extension ActiveRecord {
  
  func takeStringValue(_ value: String?, forKeyPath key: String) {
    nonFailingTakeValue(coerceString(value, forKey: key), forKeyPath: key)
  }
  func stringValue(for key: String) -> String {
    guard let v = KeyValueCoding.value(forKeyPath: key, inObject: self) else {
      return ""
    }
    return coerceValueToString(v, formatter: nil, forKey: key)
  }
  
  func takeDateValue(_ value: Date?, forKeyPath key: String) {
    nonFailingTakeValue(coerceDate(value, forKey: key), forKeyPath: key)
  }
  func dateValue(for key: String) -> Date? {
    guard let v = KeyValueCoding.value(forKeyPath: key, inObject: self) else {
      return nil
    }
    return coerceValueToDate(v, forKey: key)
  }
  
  func takeBoolValue(_ value: Bool?, forKeyPath key: String) {
    nonFailingTakeValue(coerceBool(value, forKey: key), forKeyPath: key)
  }
  func boolValue(for key: String) -> Bool? {
    guard let v = KeyValueCoding.value(forKeyPath: key, inObject: self) else {
      return nil
    }
    return coerceValueToBool(v, forKey: key)
  }
}

// TBD: This really belongs into KVC itself?! Coercion, value transfomers.

internal extension ActiveRecord {
  
  func coerceValueToString(_ value: Any?, formatter: Formatter?,
                           forKey key: String) -> String
  {
    if let fmt = formatter { return fmt.string(for: value) ?? "" }
    guard let v = value else { return "" } // hm
    
    switch v {
      case let s    as String: return s
      case let date as Date:
        if let attribute = entity[attribute: key] {
          return attribute.dateFormatter().string(from: date)
        }
        return dateTimeFormatter.string(from: date)
      
      case let b   as Bool: return b ? "yes" : "" // sigh
      case let url as URL:  return url.absoluteString
      
      default:
        return String(describing: v)
    }
  }
  
  func coerceString(_ string: String?, forKey key: String) -> Any? {
    // TBD: use a formatter to do this?!
    guard let attribute = entity[attribute: key] else {
      globalD2SLogger.log("writing raw string to attr-less key:", key)
      return string
    }
    do {
      return try attribute.coerceFromString(string)
    }
    catch {
      globalD2SLogger.error("failed to coerce string for key:", key, "\n",
                            "  attribute:", attribute)
      return string
    }
  }

  // ☢️ QUICK: LOOK AWAY. Dirty dirty stuff ahead! ☢️

  func coerceValueToDate(_ value: Any?, forKey key: String) -> Date? {
    guard let v = value else { return nil }
    
    switch v {
      case let date as Date:
        return date
      
      case let s as String:
        if s.isEmpty { return nil }
        let formatter = entity[attribute: key]?.dateFormatter()
                     ?? dateTimeFormatter
        guard let v = formatter.date(from: s) else {
          globalD2SLogger.error("failed to coerce date for string key:", key)
          return nil
        }
        return v
      
      case let i as Int: // consider Ints Unix timestamps
        return Date(timeIntervalSince1970: TimeInterval(i))
      
      default:
        globalD2SLogger.error("failed to coerce date for key:",
                              key, type(of: v))
        return nil
    }
  }
  
  func coerceDate(_ date: Date?, forKey key: String) -> Any? {
    // TBD: use a formatter to do this?!
    guard let attribute = entity[attribute: key] else {
      globalD2SLogger.log("writing raw date to attr-less key:", key)
      return date
    }
    guard let valueType = attribute.valueType else { // no type, use as-is
      return date
    }
    
    func logError() throws -> Any? {
      globalD2SLogger.log("could not coerce date key:", key)
      return nil
    }
    
    if valueType == Date.self {
      guard let d = date else { return (try? logError()) ?? nil }
      return d
    }
    if valueType == Date?.self { return date }
    
    if valueType == Int.self {
      guard let d = date else { return (try? logError()) ?? nil }
      return Int(d.timeIntervalSince1970) // Unix timestamp
    }
    if valueType == Int?.self {
      guard let d = date else { return nil }
      return Int(d.timeIntervalSince1970) // Unix timestamp
    }
    
    if valueType == String.self || valueType == String?.self { // lazy me
      guard let d = date else { return nil } // Fix for non-optional
      
      let formatter = attribute.dateFormatter()
      return formatter.string(from: d)
    }

    return (try? logError()) ?? nil
  }

  func coerceValueToBool(_ flag: Any?, forKey key: String) -> Bool? {
    guard let v = flag else { return nil }
    
    switch v {
      case let flag as Bool: return flag
      default: return UObject.boolValue(v)
    }
  }
  
  func coerceBool(_ flag: Bool?, forKey key: String) -> Any? {
    // TBD: use a formatter to do this?!
    guard let attribute = entity[attribute: key] else {
      globalD2SLogger.log("writing raw bool to attr-less key:", key)
      return flag
    }
    guard let valueType = attribute.valueType else { // no type, use as-is
      return flag
    }
    
    func logError() throws -> Any? {
      globalD2SLogger.log("could not coerce bool key:", key)
      return nil
    }
    
    if valueType == Bool.self {
      guard let flag = flag else { return (try? logError()) ?? nil }
      return flag
    }
    if valueType == Bool?.self { return flag }
    
    if valueType == Int.self {
      guard let flag = flag else { return (try? logError()) ?? nil }
      return flag ? 1 : 0
    }
    if valueType == Int?.self {
      guard let flag = flag else { return nil }
      return flag ? 1 : 0
    }
    
    if valueType == String.self || valueType == String?.self { // lazy me
      guard let flag = flag else { return nil } // Fix for non-optional
      return flag ? "true" : ""
    }
    
    return (try? logError()) ?? nil
  }
}

internal extension ActiveRecord {
  
  func nonFailingTakeValue(_ newValue: Any?, forKeyPath kp: String) {
    do {
      try KeyValueCoding.takeValue(newValue, forKeyPath: kp, inObject: self)
    }
    catch {
      globalD2SLogger.error("failed to take value for key:", kp, "\n",
                            "  on:   ", self, "\n",
                            "  error:", error)
      assertionFailure("failed to take value for key: \(kp)")
    }
  }
}
