//
//  D2SFaultContainer.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import class ZeeQL.ActiveRecord

/**
 * This takes a `D2SFault`. If it still is a fault, it shows some wildcard
 * view. If not, it shows the content.
 */
public struct D2SFaultContainer<Object: OActiveRecord, Content: View>: View {
  
  public typealias Fault = D2SFault<Object, D2SDisplayGroup<Object>>
  
  private let fault    : Fault
  private let content  : ( Object ) -> Content

  init(fault: Fault, @ViewBuilder content: @escaping ( Object ) -> Content) {
    self.fault   = fault
    self.content = content
  }
  
  public var body: some View {
    Group {
      if fault.accessingFault() { D2SRowFault() }
      else { content(fault.object).ruleObject(fault.object) }
    }
  }
}

public extension D2SFaultContainer where Content == D2STitledSummaryView {
  init(fault: Fault) {
    self.fault   = fault
    self.content = { _ in D2STitledSummaryView() }
  }
}
