//
//  ViewModifiers.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import SwiftUIRules

public extension View {
  // @inlinable crashes swiftc - SR-11444
  
  /**
   * Push the given object to the `object` environment key,
   * *AND* as an environmentObject!
   */
  //@inlinable
  func ruleObject(_ object: OActiveRecord) -> some View {
    self
      .environment(\.object, object)
      .environmentObject(object) // TBD: is this using the dynamic type?
  }
  
  //@inlinable
  func ruleContext(_ ruleContext: RuleContext) -> some View {
    self.environment(\.ruleContext, ruleContext)
  }
 
  //@inlinable
  func task(_ task: D2STask) -> some View {
    self.environment(\.task, task.stringValue) // TBD
  }
  //@inlinable
  func task(_ task: String) -> some View {
    self.environment(\.task, task)
  }
}
