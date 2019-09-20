//
//  SwiftKeyPathValueQualifier.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUIRules
import protocol ZeeQL.Qualifier
import protocol ZeeQL.QualifierEvaluation

extension RuleClosurePredicate: Qualifier {
  public func appendToStringRepresentation(_ ms: inout String) {
    ms += "<RuleClosurePredicate>"
  }
  public func appendToDescription(_ ms: inout String) {
    appendToStringRepresentation(&ms)
  }
}

extension RuleClosurePredicate: QualifierEvaluation {
  public func evaluateWith(object: Any?) -> Bool {
    guard let ruleContext = object as? RuleContext else { return false }
    return evaluate(in: ruleContext)
  }
}
