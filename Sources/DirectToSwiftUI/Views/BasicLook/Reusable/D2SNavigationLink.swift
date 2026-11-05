//
//  D2SNavigationLink.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * The same like `NavigationLink`, but this preserves the `D2SContext`
 * in the environment OF THE DESTINATION. Which otherwise starts with
 * a fresh one!
 *
 * On b6 watchOS/macOS the environment is lost on navigation.
 * That is no good :-) So we copy our keys (which are all stored within the
 * D2SContext).
 */
public struct D2SNavigationLink<Label, Destination>: View
         where Label: View, Destination: View
{
  @Environment(\.ruleContext) private var context
    // Note: cannot attach a setter, sends swiftc into loop
  
  private let destination : Destination
  private let label       : Label
  private let isActive    : Binding<Bool>?
  
  public init(destination: Destination,
              isActive: Binding<Bool>? = nil,
              @ViewBuilder label: () -> Label)
  {
    self.destination = destination
    self.label    = label()
    self.isActive = isActive
  }
  
  public var body: some View {
    Group {
      if isActive != nil {
        #if os(macOS)
          Button(action: { self.isActive!.wrappedValue = true }) {
            label
              .environmentObject(context.object)
              .ruleContext(context)
          }
          .buttonStyle(.plain)
          .navigationDestination(isPresented: isActive!) {
            destination
              .environmentObject(context.object)
              .ruleContext(context)
          }
        #else
          NavigationLink(destination: destination
                                        .environmentObject(context.object)
                                        .ruleContext(context),
                         isActive: isActive!)
          {
            label
              .environmentObject(context.object)
              .ruleContext(context)
          }
        #endif
      }
      else {
        NavigationLink(destination: destination
                                      .environmentObject(context.object)
                                      .ruleContext(context))
        {
          label
            .environmentObject(context.object)
            .ruleContext(context)
        }
      }
    }
  }
}
