//
//  Spinner.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

struct Spinner: View {
  
  let isAnimating : Bool
  let speed       : Double
  let size        : CGFloat
  
  init(isAnimating: Bool, speed: Double = 1.8, size: CGFloat = 64) {
    self.isAnimating = isAnimating
    self.speed       = speed
    self.size        = size
  }

  #if os(iOS)
  var body: some View {
    Image(systemName: "arrow.2.circlepath.circle.fill")
      .resizable()
      .frame(width: size, height: size)
      .rotationEffect(.degrees(isAnimating ? 360 : 0))
      .animation(
        Animation.linear(duration: speed)
          .repeatForever(autoreverses: false)
      )
  }
  #else // no systemImage on macOS ...
  var body: some View {
    Text("Connecting ...")
  }
  #endif
}

