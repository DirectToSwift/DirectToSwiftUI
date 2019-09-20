//
//  D2SInspectWindow.swift
//  Direct to SwiftUI (Mac)
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

#if os(macOS)
import Cocoa
import SwiftUI

class D2SInspectWindow<RootView: View>: NSWindowController {
  convenience init(rootView: RootView) {
    let hostingController = NSHostingController(
      rootView: rootView
        .frame(minWidth:  300 as CGFloat, maxWidth:  .infinity,
               minHeight: 400 as CGFloat, maxHeight: .infinity)
    )
    let window = NSWindow(contentViewController: hostingController)
    window.setContentSize(NSSize(width: 400, height: 400))
    self.init(window: window)
  }
}

#endif // macOS
