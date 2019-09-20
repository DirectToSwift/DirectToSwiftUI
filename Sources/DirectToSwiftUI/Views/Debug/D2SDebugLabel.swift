//
//  D2SDebugLabel.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public struct D2SDebugLabel<Content: View>: View {

  @Environment(\.debug) private var debug
  
  let label   : String
  let content : Content
  
  public init(_ label: String, @ViewBuilder content: () -> Content) {
    self.label   = label
    self.content = content()
  }
  
  public var body: some View {
    Group {
      if debug {
        HStack {
          Text(verbatim: label)
            .font(.footnote)
            .foregroundColor(.gray)
          content
        }
      }
      else {
        content
      }
    }
  }
}
