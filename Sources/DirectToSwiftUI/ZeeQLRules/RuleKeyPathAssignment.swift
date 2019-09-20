//
//  RuleKeyPathAssignment.swift
//  SwiftUIRules
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUIRules
import struct ZeeQL.KeyValueCoding

/**
 * RuleKeyPathAssignment
 *
 * This RuleAction object evaluates the action value as a lookup against the
 * _context_. Which then can trigger recursive rule evaluation (if the queried
 * key is itself a rule based value).
 *
 * In a model it looks like:
 * <pre>  <code>user.role = 'Manager' => bannerColor = defaultColor</code></pre>
 *
 * The <code>bannerColor = defaultColor</code> represents the
 * D2SRuleKeyPathAssignment.
 * When executed, it will query the RuleContext for the 'defaultColor' and
 * will return that in fireInContext().
 * <p>
 * Note that this object does *not* perform a
 * takeValueForKey(value, 'bannerColor'). It simply returns the value in
 * fireInContext() for further processing at upper layers.
 *
 * @see RuleAction
 * @see RuleAssignment
 */
public struct RuleKeyPathAssignment<K: DynamicEnvironmentKey>
              : RuleCandidate, RuleAction
{
  public let key     : K.Type
  public let keyPath : [ String ]
  
  public init(_ key: K.Type, _ keyPath: [ String ]) {
    self.key     = key
    self.keyPath = keyPath
  }
  public init(_ key: K.Type, _ keyPath: String) {
    self.key     = key
    self.keyPath = keyPath.components(separatedBy: ".")
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
    return KeyValueCoding.value(forKeyPath: keyPath, inObject: context)
  }
}
