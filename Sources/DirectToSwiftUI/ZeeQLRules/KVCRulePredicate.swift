//
//  KVCRulePredicate.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import protocol SwiftUIRules.RulePredicate
import struct   SwiftUIRules.RuleContext
import protocol ZeeQL.QualifierEvaluation
import struct   ZeeQL.KeyValueQualifier
import struct   ZeeQL.KeyComparisonQualifier
import struct   ZeeQL.CompoundQualifier
import struct   ZeeQL.BooleanQualifier

public extension QualifierEvaluation {

  func evaluate(in ruleContext: RuleContext) -> Bool {
    return evaluate(with: ruleContext)
  }
  
}

// TBD: I think conformance has to be declared manually and can't be attached
//      to the protocol?

extension KeyValueQualifier      : @retroactive RulePredicate {}
extension KeyComparisonQualifier : @retroactive RulePredicate {}
extension BooleanQualifier       : @retroactive RulePredicate {}

extension CompoundQualifier      : @retroactive RulePredicate {
  
  public var rulePredicateComplexity : Int {
    return qualifiers.reduce(0) {
      let complexity = ($1 as? RulePredicate)?.rulePredicateComplexity ?? 1
      return $0 + complexity
    }
  }
}

public extension SwiftUIRules.RuleComparisonOperation {
  
  init?(_ op: ZeeQL.ComparisonOperation) {
    switch op {
      case .other, .in, .notIn, .like, .caseInsensitiveLike,
           .SQLLike, .SQLCaseInsensitiveLike,
           .contains, .caseInsensitiveContains,
           .beginsWith, .caseInsensitiveBeginsWith,
           .endsWith, .caseInsensitiveEndsWith:
        return nil
      case .equalTo:            self = .equal
      case .notEqualTo:         self = .notEqual
      case .greaterThan:        self = .greaterThan
      case .greaterThanOrEqual: self = .greaterThanOrEqual
      case .lessThan:           self = .lessThan
      case .lessThanOrEqual:    self = .lessThanOrEqual
    }
  }
}

public extension ZeeQL.ComparisonOperation {
  
  init(_ op: SwiftUIRules.RuleComparisonOperation) {
    switch op {
      case .equal:              self = .equalTo
      case .notEqual:           self = .notEqualTo
      case .lessThan:           self = .lessThan
      case .greaterThan:        self = .greaterThan
      case .lessThanOrEqual:    self = .lessThanOrEqual
      case .greaterThanOrEqual: self = .greaterThanOrEqual
    }
  }
  
}
