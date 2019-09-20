//
//  RuleKeyPathPredicateExtras.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

public extension RuleKeyPathPredicate {
  // Any Predicates to support ActiveRecord dynamic properties.
  
  init<Value>(keyPath: Swift.KeyPath<RuleContext, Any?>, value: Value) {
    self.init { ruleContext in
      eq(ruleContext[keyPath: keyPath], value)
    }
  }
  init<Value>(keyPath: Swift.KeyPath<RuleContext, Any?>, value: Value?) {
    self.init { ruleContext in
      eq(ruleContext[keyPath: keyPath], value)
    }
  }

  init<Value>(keyPath: Swift.KeyPath<RuleContext, Any?>,
              operation: SwiftUIRules.RuleComparisonOperation,
              value: Value)
  {
    let op = ZeeQL.ComparisonOperation(operation)
    self.init() { ruleContext in
      op.compare(ruleContext[keyPath: keyPath], value)
    }
  }
  init<Value>(keyPath: Swift.KeyPath<RuleContext, Any?>,
              operation: SwiftUIRules.RuleComparisonOperation,
              value: Value?)
  {
    let op = ZeeQL.ComparisonOperation(operation)
    self.init() { ruleContext in
      op.compare(ruleContext[keyPath: keyPath], value)
    }
  }
}
