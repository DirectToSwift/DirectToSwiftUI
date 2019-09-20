//
//  KVCRuleSelfAssignment.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import protocol SwiftUIRules.DynamicEnvironmentKey
import protocol SwiftUIRules.RuleAction
import protocol SwiftUIRules.RuleCandidate
import struct   SwiftUIRules.RuleContext
import struct   ZeeQL.KeyValueCoding

/*
* KVCRuleSelfAssignment
*
* This is an abstract assignment class which evaluates the right side of the
* assignment as a keypath against itself. E.g.
*
*      color = currentColor
*
* Will call 'currentColor' on the assignment object. Due to this the class is
* abstract since the subclass must provide appropriate KVC keys for the
* operation.
*/
open class KVCRuleSelfAssignment<K: DynamicEnvironmentKey>
           : RuleCandidate, RuleAction
{
  let key     : K.Type
  let keyPath : String
  
  public init(key: K.Type, keyPath: String) {
    self.key     = key
    self.keyPath = keyPath
  }
  
  public var candidateKeyType: ObjectIdentifier {
    return ObjectIdentifier(key)
  }
  public func isCandidateForKey<K: DynamicEnvironmentKey>(_ key: K.Type)
              -> Bool
  {
    return self.key == key
  }
  
  public func fireInContext(_ context: RuleContext) -> Any? {
    return KeyValueCoding.value(forKeyPath: keyPath, inObject: self)
  }
}
