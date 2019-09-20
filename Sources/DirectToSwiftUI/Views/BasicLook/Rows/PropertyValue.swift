//
//  D2SPropertyValueRow.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import protocol SwiftUI.View

public extension BasicLook.Row {
  /**
   * A row which just emits the property value component.
   *
   * E.g. useful in Forms.
   */
  struct PropertyValue: View {
    
    public var body: some View {
      D2SComponentView()
    }
  }
}
