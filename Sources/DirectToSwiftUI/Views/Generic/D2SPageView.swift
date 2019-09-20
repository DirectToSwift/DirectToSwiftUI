//
//  D2SPageView.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * Show the View which the `page` key yields.
 *
 * Also configures the navbar title on iOS.
 */
public struct D2SPageView: View {
  
  #if os(iOS)
    @Environment(\.navigationBarTitle) private var title
    @Environment(\.page)               private var page
  
    public var body: some View {
      return page
        .navigationBarTitle(Text(title), displayMode: .inline)
    }
  #else
    @Environment(\.page) public var body
  #endif
}
