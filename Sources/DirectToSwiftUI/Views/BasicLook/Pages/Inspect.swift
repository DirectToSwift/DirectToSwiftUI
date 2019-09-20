//
//  Inspect.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension BasicLook.Page {
  /**
   * A readonly view showing the properties of an object.
   *
   * Iterates over the `displayPropertyKeys` and shows the respective views.
   */
  struct Inspect: View {

    @Environment(\.debugComponent) private var debugComponent
    
    public init() {}

    // TBD: this should also do the prefetching of relationships?
    
    #if os(iOS)
      struct NavbarItems: View {
        
        @Environment(\.isObjectEditable) private var isEditable
          // TODO: add keys to make this per object
        
        var body: some View {
          Group {
            if isEditable {
              D2SNavigationLink(destination: D2SPageView().task(.edit)) {
                Text("Edit")
              }
            }
          }
        }
      }
    
      public var body: some View {
        VStack {
          D2SDisplayPropertiesList()
          debugComponent
        }
        .navigationBarItems(trailing: NavbarItems())
      }
    #else // TBD: how on others?
      public var body: some View {
        VStack {
          D2SDisplayPropertiesList()
          debugComponent
        }
      }
    #endif
  }
}
