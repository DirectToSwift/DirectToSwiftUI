//
//  RuleOperatorExtras.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import ZeeQL

// e.g. \.attribute.valueType == Date.self
public func ==<VT>(lhs: Swift.KeyPath<RuleContext, AttributeValue.Type?>,
                   rhs: VT.Type)
            -> some RulePredicate
{
  RuleKeyPathPredicate<AttributeValue.Type> { ruleContext in
    guard let v = ruleContext[keyPath: lhs] else { return false }
    return ObjectIdentifier(v) == ObjectIdentifier(rhs)
  }
}

// MARK: - Any Predicates to support ActiveRecord dynamic properties

// e.g. \.object.name == "Hello"
public func ==<V>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: V)
            -> some RulePredicate
{
  RuleKeyPathPredicate<Any?>(keyPath: lhs, value: rhs)
}

// e.g. \.person.name != "Donald"
public func !=<Value>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: Value)
              -> some RulePredicate
{
  RuleNotPredicate(predicate:
    RuleKeyPathPredicate<Value>(keyPath: lhs, value: rhs))
}

// e.g. \.person.age < 45
public func < <Value>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: Value)
              -> some RulePredicate
{
  RuleKeyPathPredicate<Value>(keyPath: lhs, operation: .lessThan, value: rhs)
}
public func <= <Value>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: Value)
              -> some RulePredicate
{
  RuleKeyPathPredicate<Value>(keyPath: lhs, operation: .lessThanOrEqual,
                              value: rhs)
}

// e.g. \.person.age > 45
public func > <Value>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: Value)
              -> some RulePredicate
{
  RuleKeyPathPredicate<Value>(keyPath: lhs, operation: .greaterThan, value: rhs)
}
public func >= <Value>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: Value)
              -> some RulePredicate
{
  RuleKeyPathPredicate<Value>(keyPath: lhs, operation: .greaterThanOrEqual,
                              value: rhs)
}

// e.g. \.person === manager
public func ===<Value>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: Value)
              -> some RulePredicate where Value : AnyObject
{
  RuleKeyPathPredicate<Value>() { ruleContext in
    guard let lhs = ruleContext[keyPath: lhs] else { return false }
    return ObjectIdentifier(lhs as AnyObject) == ObjectIdentifier(rhs)
  }
}
// e.g. \.person !== manager
public func !==<Value>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: Value)
              -> some RulePredicate where Value : AnyObject
{
  RuleKeyPathPredicate<Value>() { ruleContext in
    guard let lhs = ruleContext[keyPath: lhs] else { return true }
    return ObjectIdentifier(lhs as AnyObject) != ObjectIdentifier(rhs)
  }
}

// variants w/ optional Value

// e.g. \.object.name == "Hello"
public func ==<V>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: V?)
            -> some RulePredicate
{
  RuleKeyPathPredicate<Any?>(keyPath: lhs, value: rhs)
}

// e.g. \.person.name != "Donald"
public func !=<Value>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: Value?)
              -> some RulePredicate
{
  RuleNotPredicate(predicate:
    RuleKeyPathPredicate<Value>(keyPath: lhs, value: rhs))
}

// e.g. \.person.age < 45
public func < <Value>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: Value?)
              -> some RulePredicate
{
  RuleKeyPathPredicate<Value>(keyPath: lhs, operation: .lessThan, value: rhs)
}
public func <= <Value>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: Value?)
              -> some RulePredicate
{
  RuleKeyPathPredicate<Value>(keyPath: lhs, operation: .lessThanOrEqual,
                              value: rhs)
}

// e.g. \.person.age > 45
public func > <Value>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: Value?)
              -> some RulePredicate
{
  RuleKeyPathPredicate<Value>(keyPath: lhs, operation: .greaterThan, value: rhs)
}
public func >= <Value>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: Value?)
              -> some RulePredicate
{
  RuleKeyPathPredicate<Value>(keyPath: lhs, operation: .greaterThanOrEqual,
                              value: rhs)
}

// e.g. \.person === manager
public func ===<Value>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: Value?)
              -> some RulePredicate where Value : AnyObject
{
  RuleKeyPathPredicate<Value>() { ruleContext in
    guard let lhs = ruleContext[keyPath: lhs] else { return rhs == nil }
    guard let rhs = rhs else { return false }
    return ObjectIdentifier(lhs as AnyObject) == ObjectIdentifier(rhs)
  }
}
// e.g. \.person !== manager
public func !==<Value>(lhs: Swift.KeyPath<RuleContext, Any?>, rhs: Value?)
              -> some RulePredicate where Value : AnyObject
{
  RuleKeyPathPredicate<Value>() { ruleContext in
    guard let lhs = ruleContext[keyPath: lhs] else { return rhs != nil }
    guard let rhs = rhs else { return true }
    return ObjectIdentifier(lhs as AnyObject) != ObjectIdentifier(rhs)
  }
}

// e.g. \.user === nil (seems to be required to make it unambiguous)
public func ===<Value>(lhs: Swift.KeyPath<RuleContext, Value?>, rhs: Value?)
              -> some RulePredicate where Value : ActiveRecord
{
  RuleKeyPathPredicate<Value>() { ruleContext in
    guard let lhs = ruleContext[keyPath: lhs] else { return rhs == nil }
    guard let rhs = rhs else { return false }
    return ObjectIdentifier(lhs as AnyObject) == ObjectIdentifier(rhs)
  }
}
// e.g. \.user !== nil (seems to be required to make it unambiguous)
public func !==<Value>(lhs: Swift.KeyPath<RuleContext, Value?>, rhs: Value?)
              -> some RulePredicate where Value : ActiveRecord
{
  RuleKeyPathPredicate<Value>() { ruleContext in
    guard let lhs = ruleContext[keyPath: lhs] else { return rhs != nil }
    guard let rhs = rhs else { return true }
    return ObjectIdentifier(lhs as AnyObject) != ObjectIdentifier(rhs)
  }
}


// MARK: - Any Assignments

// TBD: Just for String right now, we could add more if necessary.

// \.title <= \.object.title
// Note: This only works on 1-level, because Any? does not convert to dynamic
//       keypath lookup.
// FIXME: So the AR should return KeyValueCodingObject instead of Any?
public func <= (lhs: Swift.KeyPath<RuleContext, String>,
                rhs: Swift.KeyPath<RuleContext, Any?>)
               -> RuleTypeIDPathAnyAssignment<String>
{
  RuleTypeIDPathAnyAssignment<String>(lhs, rhs)
}

public struct RuleTypeIDPathAnyAssignment<LeftValue>: RuleCandidate, RuleAction
{
  
  public let typeID  : ObjectIdentifier
  public let keyPath : Swift.KeyPath<RuleContext, Any?>
  public let coerce  : ( Any ) -> LeftValue?
  
  public init(_ typeID  : ObjectIdentifier,
              _ keyPath : Swift.KeyPath<RuleContext, Any?>,
              _ coerce  : @escaping ( Any ) -> LeftValue? = { _ in nil })
  {
    self.typeID  = typeID
    self.keyPath = keyPath
    self.coerce  = coerce
  }
  public init(_ keyPath   : Swift.KeyPath<RuleContext, LeftValue>,
              _ valuePath : Swift.KeyPath<RuleContext, Any?>,
              _ coerce    : @escaping ( Any ) -> LeftValue? = { _ in nil })
  {
    let typeID = RuleContext.typeIDForKeyPath(keyPath)
    self.init(typeID, valuePath, coerce)
  }

  public var candidateKeyType: ObjectIdentifier {
    return typeID
  }

  public func isCandidateForKey<K: DynamicEnvironmentKey>(_ key: K.Type)
              -> Bool
  {
    return self.typeID == ObjectIdentifier(key)
  }
  
  public func fireInContext(_ context: RuleContext) -> Any? {
    let anyValue = context[keyPath: keyPath]
    if let value = anyValue as? LeftValue { return value }
    guard let value = anyValue else { return nil } // unwrap
    return coerce(value) ?? anyValue
  }
}

/* test it
private func test() {
  let kp  = \RuleContext.object
  let kp2 = \RuleContext.object.film
  let x   = \RuleContext.title <= \RuleContext.object.film // works
  //  let x = \RuleContext.title <= \RuleContext.object.film.title // fails
  => because film returns Any? which doesn't do dynamic lookup
}
*/
