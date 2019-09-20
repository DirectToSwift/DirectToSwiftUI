//
//  D2SMobilePageWrapper.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension BasicLook.PageWrapper {

  /**
   * Wraps the page in a navigation view.
   */
  struct Navigation: View {
    
    @EnvironmentObject var ruleEnvironment : D2SRuleEnvironment

    @available(OSX, unavailable)
    struct RootTitledPageView: View {
      
      #if os(macOS) // no .navigationBarTitle on macOS
        var body: some View { D2SPageView() }
      #else
        @Environment(\.navigationBarTitle) private var title
        var body: some View {
          D2SPageView()
            .navigationBarTitle(title) // explict override for 1st page
        }
      #endif
    }

    #if os(macOS) // no .navigationBarTitle on macOS
      public var body: some View {
        NavigationView {
          D2SPageView()
        }
      }
    #elseif os(watchOS)
      public var body: some View { // no NavigationView on watchOS
        RootTitledPageView()
      }
    #else // iOS, watchOS
      public var body: some View {
        NavigationView {
          RootTitledPageView()
        }
      }
    #endif
  }
}
