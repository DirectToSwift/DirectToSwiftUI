//
//  D2STitledSummaryView.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public struct D2STitledSummaryView: View {
  
  let font = Font.headline
  
  public var body: some View {
    VStack(alignment: .leading) {
      D2STitleText()
        .font(font)
        .lineLimit(1)
      HStack {
        D2SSummaryView()
        Spacer()
      }
    }
    .frame(maxWidth: .infinity)
  }
}
