//
//  D2SRowFault.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * The wildcard View to use if a fault object has not been resolved yet.
 */
struct D2SRowFault: View {
  #if false
    var body: some View {
      HStack {
        Spacer()
        Text("⏳") // that is too intrusive
      }
    }
  #else
    var body: some View {
      // show something nicer, some nice Path with a gray fake object
      Spacer()
        .frame(minHeight: 32)
    }
  #endif
}
