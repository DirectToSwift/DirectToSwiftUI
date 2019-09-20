//
//  QueryList.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension BasicLook.Page {
  
  /**
   * Those functions select a proper query list view for the current platform.
   * It is useful if you want to embed a D2SQueryListPage page in your own
   * View which binds to the `query` task itself, so we can't find it using the
   * rule system.
   */
  #if os(macOS)
    static func QueryList() -> some View { AppKit.WindowQueryList() }
  #elseif os(iOS)
    static func QueryList() -> some View { UIKit.QueryList() }
  #elseif os(watchOS)
    static func QueryList() -> some View { SmallQueryList()  }
  #endif
}
