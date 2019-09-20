//
//  D2SDebugBox.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

struct D2SDebugBox<Content: View>: View {
  
  let content : Content
  
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        content
      }
      // Spacer() // consumes too much space, doesn't shrink?
    }
    .padding(8)
    .background(RoundedRectangle(cornerRadius: 4)
                .stroke()
                .foregroundColor(.red))
    .padding()
    .frame(maxWidth: .infinity, maxHeight: 200)
  }
}
