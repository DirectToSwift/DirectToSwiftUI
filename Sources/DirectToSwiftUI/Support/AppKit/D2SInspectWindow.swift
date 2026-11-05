//
//  D2SInspectWindow.swift
//  Direct to SwiftUI (Mac)
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

#if os(macOS)
import Cocoa
import SwiftUI

private struct CloseInspectWindowKey: EnvironmentKey {
  static let defaultValue : (() -> Void)? = nil
}

extension EnvironmentValues {
  /// Closes the `D2SInspectWindow` which hosts the View.
  var closeInspectWindow : (() -> Void)? {
    get { self[CloseInspectWindowKey.self] }
    set { self[CloseInspectWindowKey.self] = newValue }
  }
}

class D2SInspectWindow<RootView: View>: NSWindowController {
  convenience init(rootView: RootView) {
    // The stack is required for the `D2SNavigationLink`s in the pages.
    weak var hostedWindow : NSWindow?
    let hostingController = NSHostingController(
      rootView: NavigationStack { rootView }
        .frame(minWidth:  400 as CGFloat, maxWidth:  .infinity,
               minHeight: 400 as CGFloat, maxHeight: .infinity)
        .environment(\.closeInspectWindow, { hostedWindow?.close() })
    )
    let window = NSWindow(contentViewController: hostingController)
    hostedWindow = window
    window.setContentSize(NSSize(width: 520, height: 640))
    self.init(window: window)
  }
}

#endif // macOS
