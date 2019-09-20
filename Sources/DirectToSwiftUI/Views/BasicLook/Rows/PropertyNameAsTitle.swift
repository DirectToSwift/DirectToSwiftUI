//
//  PropertyNameAsTitle.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension BasicLook.Row {
  /**
   * A row which shows the property name as a title,
   * and the property value below.
   */
  struct PropertyNameAsTitle: View {
    
    let font = Font.headline
    
    public var body: some View {
      VStack(alignment: .leading) {
        D2SPropertyName()
          .font(self.font)
        D2SComponentView()
      }
    }
  }
}
