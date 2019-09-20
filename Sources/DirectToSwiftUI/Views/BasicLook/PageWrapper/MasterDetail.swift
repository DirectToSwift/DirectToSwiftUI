//
//  D2SMasterDetailPageWrapper.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension BasicLook.PageWrapper {
  /**
   * NavigationView really works badly on macOS. This is kinda like a
   * replacement but lacks the split view ...
   *
   * Note: This is only really intended for macOS to workaround navview issues.
   */
  struct MasterDetail: View {
    
    @Environment(\.ruleContext) private var ruleContext
    
    #if os(macOS) // use an own, custom component
      public var body: some View {
        EntityMasterDetailPage()
          .ruleContext(ruleContext)
      }
    #elseif os(watchOS) // TODO: master detail for watchOS?
      public var body: some View {
        D2SPageView()
          .ruleContext(ruleContext)
      }
    #else
      public var body: some View {
        NavigationView {
          D2SPageView()
            .ruleContext(ruleContext)

          // FIXME: Show something useful as the default, maybe a query page
          Text("Select an Entity ")
              .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ruleContext(ruleContext)
      }
    #endif
  }
}
