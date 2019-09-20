//
//  PropertyNameValue.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension BasicLook.Row {

  /**
   * A row which displays the property name on the left and the value on the
   * right.
   */
  struct PropertyNameValue: View {
    
    public var body: some View {
      HStack(alignment: .firstTextBaseline) {
        D2SPropertyName()
        Spacer()
        D2SComponentView()
      }
    }
  }
}
