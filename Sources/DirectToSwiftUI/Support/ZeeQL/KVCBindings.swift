//
//  KVCBindings.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import ZeeQL

public extension KeyValueCodingType where Self : MutableKeyValueCodingType {
  
  func binding(_ key: String) -> Binding<Any?> {
    return KeyValueCoding.binding(key, for: self)
  }
}

public extension KeyValueCoding { // bindings for KVC keys
  
  static func binding(_ key: String, for object: Any?) -> Binding<Any?> {
    if let object = object {
      return Binding<Any?>(get: {
        KeyValueCoding.value(forKey: key, inObject: object)
      }) {
        newValue in
        do {
          try KeyValueCoding.takeValue(newValue, forKey: key, inObject: object)
        }
        catch {
          globalD2SLogger.error("failed to take value for binding:",
                                key, "\n", "  on:", object, "\n", error)
          assertionFailure("failed to take value for binding: \(key)")
        }
      }
    }
    else {
      return Binding<Any?>(get: { return nil }) { newValue in
        globalD2SLogger.error("attempt to write to nil binding:", key)
        assertionFailure("attempt to write to nil binding: \(key)")
      }
    }
  }
  
  static func binding(_ key: String,
                for object: KeyValueCodingType & MutableKeyValueCodingType)
              -> Binding<Any?>
  {
    return Binding<Any?>(get: {
      object.value(forKey: key)
    }) {
      newValue in
      do {
        try object.takeValue(newValue, forKey: key)
      }
      catch {
        globalD2SLogger.error("failed to take value for binding:",
                              key, "\n", "  on:", object, "\n", error)
        assertionFailure("failed to take value for binding: \(key)")
      }
    }
  }
}
