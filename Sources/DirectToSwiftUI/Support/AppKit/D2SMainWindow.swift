//
//  D2SMainWindow.swift
//  Direct to SwiftUI (Mac)
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

#if os(macOS)

import protocol ZeeQL.Adaptor
import class    SwiftUI.NSHostingView
import Cocoa

/**
 * Function to create a main window.
 */
public func D2SMakeWindow(adaptor: Adaptor, ruleModel : RuleModel)
            -> NSWindow
{
  let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
      styleMask: [
        .titled,
        .closable, .miniaturizable, .resizable,
        .fullSizeContentView
      ],
      backing: .buffered, defer: false
  )
  window.center()
  window.setFrameAutosaveName("D2SWindow")

  window.titleVisibility             = .hidden // just hides the title string
  window.titlebarAppearsTransparent  = true
  window.isMovableByWindowBackground = true

  let view = D2SMainView(adaptor: adaptor, ruleModel: ruleModel)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
  window.contentView = NSHostingView(rootView: view)
  return window
}

#endif
