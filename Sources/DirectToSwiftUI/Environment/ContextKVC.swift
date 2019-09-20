//
//  D2SContextKVC.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUIRules
import protocol ZeeQL.KeyValueCodingType
import struct   SwiftUI.EnvironmentValues

extension EnvironmentValues: KeyValueCodingType {
  
  /**
   * SwiftUI.EnvironmentValues dispatches KVC calls to its attached
   * `ruleContext`.
   */
  public func value(forKey k: String) -> Any? {
    return ruleContext.value(forKey: k)
  }
}

extension RuleContext: KeyValueCodingType {

  /**
   * RuleContext KVC uses a static map `kvcToEnvKey` which is setup in the
   * `D2SEnvironmentKeys.swift` file.
   *
   * Users can expose additional `DynamicEnvironmentKey` via KVC using the
   * `D2SContextKVC.expose()` static function.
   */
  public func value(forKey k: String) -> Any? {
    guard let entry = D2SContextKVC.kvcToEnvKey[k] else { return nil }
    return entry.value(self)
  }
  
}

public enum D2SContextKVC {
  // kvcToEnvKey is in `D2SEnvironmentKeys.swift`
  
  /**
   * Expose a custom `DynamicEnvironmentKey` using a `KeyValueCoding`
   * key.
   */
  public static func expose<K>(_ environmentKey: K.Type, as kvcKey: String)
           where K: DynamicEnvironmentKey
  {
    kvcToEnvKey[kvcKey] = KVCMapEntry(environmentKey)
  }

  class AnyKVCMapEntry {
    func value(_ ctx: RuleContext) -> Any? {
      fatalError("subclass responsibility: \(#function)")
    }
    func isType<K2: DynamicEnvironmentKey>(_ type: K2.Type) -> Bool {
      fatalError("subclass responsibility: \(#function)")
    }

    func makeValueAssignment(_ value: Any?) -> (RuleCandidate & RuleAction)? {
      fatalError("subclass responsibility: \(#function)")
    }
    
    func makeKeyAssignment(_ rhsEntry: AnyKVCMapEntry)
         -> (RuleCandidate & RuleAction)?
    {
      fatalError("subclass responsibility: \(#function)")
    }
    func makeKeyAssignment<K: DynamicEnvironmentKey>(to lhs: K.Type)
         -> (RuleCandidate & RuleAction)?
    {
      fatalError("subclass responsibility: \(#function)")
    }
    func makeKeyPathAssignment(_ keyPath: String)
         -> (RuleCandidate & RuleAction)?
    {
      fatalError("subclass responsibility: \(#function)")
    }
  }
  final class KVCMapEntry<K: DynamicEnvironmentKey>: AnyKVCMapEntry {
    init(_ key: K.Type) {}
    
    override
    func isType<K2: DynamicEnvironmentKey>(_ type: K2.Type) -> Bool {
      return K.self == type
    }
    
    override func value(_ ctx: RuleContext) -> Any? {
      return ctx[dynamic: K.self]
    }
    
    override func makeValueAssignment(_ value: Any?)
                  -> (RuleCandidate & RuleAction)?
    {
      guard let typedValue = value as? K.Value else {
        assertionFailure("invalid value for envkey: \(value as Any) \(K.self)")
        return nil
      }
      return RuleValueAssignment(K.self, typedValue)
    }
    
    override
    func makeKeyAssignment(_ rhsEntry: AnyKVCMapEntry)
         -> (RuleCandidate & RuleAction)?
    {
      return rhsEntry.makeKeyAssignment(to: K.self)
    }
    
    override
    func makeKeyAssignment<K2: DynamicEnvironmentKey>(to lhs: K2.Type)
         -> (RuleCandidate & RuleAction)?
    {
      return RuleKeyAssignment(K2.self, K.self)
    }

    override
    func makeKeyPathAssignment(_ keyPath: String)
         -> (RuleCandidate & RuleAction)?
    {
      return RuleKeyPathAssignment(K.self, keyPath)
    }
  }
}
