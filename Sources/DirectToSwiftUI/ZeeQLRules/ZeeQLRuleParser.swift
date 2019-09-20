//
//  D2SRuleParser.swift
//  SwiftUIRules
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

#if canImport(ZeeQL)

import struct   Foundation.CharacterSet
import class    Foundation.PropertyListSerialization
import func     ZeeQL.qualifierWith
import protocol ZeeQL.Qualifier
import protocol ZeeQL.QualifierEvaluation
import class    SwiftUIRules.RuleModel
import class    SwiftUIRules.Rule
import protocol SwiftUIRules.RuleCandidate
import protocol SwiftUIRules.RuleAction
import protocol SwiftUIRules.RulePredicate

public extension RuleModel {
  
  func add(_ rules: String...) {
    for ruleString in rules {
      guard let rule = Rule(ruleString) else {
        globalD2SLogger.error("could not parse rule:", ruleString)
        continue
      }
      addRule(rule)
    }
  }
}


fileprivate let quotes = CharacterSet(charactersIn: "\"'")
fileprivate let escape : Character = "\\"

fileprivate func trim(_ s: String) -> String {
  return s.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
}

extension Rule {
  
  public convenience init?(_ string: String) {
    // Note: stupid port of GETobjects version.
    guard !string.isEmpty else { return nil }
    
    let lhsRhsSplitter = string.range(of: "=>", skippingQuotes: quotes,
                                      escapeUsing: escape)
    
    let qualifier: Qualifier? = {
      guard let idx = lhsRhsSplitter?.lowerBound else { return nil }
      return qualifierWith(format: String(string[..<idx]))
    }()
    let qualifierEvaluation : RulePredicate
    if let q = qualifier {
      guard let qe = q as? RulePredicate else {
        globalD2SLogger.error(
          "Cannot use non-RulePredicate qualifier in rule:", q)
        return nil
      }
      qualifierEvaluation = qe
    }
    else { qualifierEvaluation = BooleanQualifier.trueQualifier }

    let remainder : String = {
      guard let split = lhsRhsSplitter else { return string }
      return String(string[split.upperBound...])
    }()

    /* scan for priority separator */
    let prioSplitter = remainder.range(of: ";", skippingQuotes: quotes,
                                       escapeUsing: escape)
    let priority : Priority = {
      guard let idx = prioSplitter?.upperBound else { return .normal }
      return Priority(trim(String(remainder[idx...]))) ?? .normal
    }()
    
    let actionString : String = {
      guard let idx = prioSplitter?.lowerBound else { return remainder }
      return String(remainder[..<idx])
    }()
    
    func parseAction(_ string: String) -> (RuleCandidate & RuleAction)? {
      let s = trim(string)
      guard !s.isEmpty else { return nil }
      
      if s.hasPrefix("(") {
        globalD2SLogger.error("assignment type casts are not yet supported:",
                              string)
        assertionFailure("assignment type casts are not yet supported")
        return nil
      }
      
      guard let splitter = s.range(of: "<=", skippingQuotes: quotes,
                                   escapeUsing: escape)
                        ?? s.range(of: "=", skippingQuotes: quotes,
                                   escapeUsing: escape) else {
        globalD2SLogger.error("missing '=' in assignment:", s)
        return nil
      }
      
      let keyString   = trim(String(s[..<splitter.lowerBound]))
      let valueString = trim(String(s[splitter.upperBound...]))
      guard !keyString.isEmpty && !valueString.isEmpty else {
        globalD2SLogger.error("missing key or value in assignment:", s)
        return nil
      }
      
      // TODO: Support `RuleAssignment` classes
      
      guard let keyEntry = D2SContextKVC.kvcToEnvKey[keyString] else {
        globalD2SLogger.error("unsupported dynamic env key:", keyString)
        assertionFailure("unsupported key: \(keyString)")
        return nil
      }
      
      let c0 = valueString.first!
      
      if c0 == "'" || c0 == "\"" || c0 == "{" || c0 == "(" {
        guard let data = valueString.data(using: .utf8) else {
          assertionFailure("could not render string as data.")
          return nil
        }
        do {
          let plist = try PropertyListSerialization
            .propertyList(from: data, options: [], format: nil)
          return keyEntry.makeValueAssignment(plist)
        }
        catch {
          globalD2SLogger.error("could not parse plist value:", s, error)
          return nil
        }
      }
      
      switch valueString {
        case "true", "YES": return keyEntry.makeValueAssignment(true)
        case "false", "NO": return keyEntry.makeValueAssignment(false)
        case "nil", "NULL": return keyEntry.makeValueAssignment(nil)
        default: break
      }
      
      return keyEntry.makeKeyPathAssignment(valueString)
    }
    
    guard let action = parseAction(actionString) else {
      return nil
    }
    
    self.init(when: qualifierEvaluation, do: action, at: priority)
  }
}

#endif // ZeeQL
