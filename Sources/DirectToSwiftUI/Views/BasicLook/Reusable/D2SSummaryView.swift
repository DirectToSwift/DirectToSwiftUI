//
//  D2SSummaryView.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * Displays a comma separated list of the `displayPropertyKeys` of the current
 * `object`.
 *
 * Use a an empty string for the `displayNameForProperty` to just show the
 * value.
 */
public struct D2SSummaryView: View {
  
  @EnvironmentObject private var object : OActiveRecord
  
  @Environment(\.displayPropertyKeys) private var displayPropertyKeys
  @Environment(\.ruleContext)         private var ruleContext

  private func summary(for object: ActiveRecordType) -> String {
    return summary(for: object, entity: object.entity)
  }
  private func summary(for object: DatabaseObject, entity: Entity,
                       fieldSeparator : String = ": ",
                       itemSeparator  : String = ", ") -> String
  {
    var localContext = ruleContext
    var summary = ""
    
    func stringForValue(_ value: Any) -> String {
      // We can't use the D2SDisplay (`.component`) things here :-/
      // So we essentially replicate the logic ...
      // We can't even reflect on `component`, because it is the `AnyView`.
      // TBD: use an own wrapping AnyView? Which we could then ask for it's
      //      stringValue
      
      let attribute = localContext.optional(D2SKeys.attribute.self)
      
      if let attribute = attribute, attribute.isPassword {
        return "🔐"
      }
      
      if let s = value as? String { return s }
      
      if let date = value as? Date {
        if let attribute = attribute {
          return attribute.dateFormatter().string(from: date)
        }
        return DateFormatter().string(from: date)
      }
      
      return String(describing: value)
    }
    
    var isFirst = true
    for name in displayPropertyKeys {
      localContext.propertyKey = name
      defer { localContext.propertyKey = "" }
      
      guard let value = localContext.propertyValue else { continue }
      if let v = value as? String, v.isEmpty { continue } // hide empty
      
      if value is Data { continue } // No data in summary
      
      if isFirst { isFirst = false }
      else { summary += itemSeparator }

      let name = localContext.displayNameForProperty
      if !name.isEmpty { // do not add separator if name is empty
        summary += name
        summary += fieldSeparator
      }
      summary += stringForValue(value)
    }
    
    return summary
  }
  
  private var objectSummary: String {
    let o = object // makes it work, cannot directly use `object` ...
    return self.summary(for: o)
  }

  public var body: some View {
    // The .lineLimit isn't used on macOS (stays 1 line)
    //  .fixedSize(horizontal: false, vertical: true)
    // makes it wrap, but then yields other layout issues.
    Text(objectSummary) // doesn't wrap on macOS?
      .lineLimit(3) // TODO: make it a rule
  }
}
