//
//  D2SDisplayEmail.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import struct ZeeQL.KeyValueCoding

#if canImport(AppKit)
  import class AppKit.NSWorkspace
#elseif canImport(UIKit) && !os(watchOS)
  import class UIKit.UIApplication
#endif

public extension BasicLook.Property.Display {
  
  /**
   * Shows the email as a tappable text (where supported).
   *
   * To make it work on iOS, you need to add `mailto` to the
   * `LSApplicationQueriesSchemes` array property in the Info.plist.
   * Note: Doesn't work in the simulator.
   */
  struct Email: View {

    typealias String = Swift.String

    public init() {}
    
    @EnvironmentObject var object : OActiveRecord
    
    @Environment(\.propertyKey)         private var propertyKey
    @Environment(\.propertyValue)       private var propertyValue
    @Environment(\.displayStringForNil) private var stringForNil
    @Environment(\.debug)               private var debug

    private var stringValue: String {
      guard let v = propertyValue else { return stringForNil }
      return object.coerceValueToString(v, formatter: nil, forKey: propertyKey)
    }

    #if os(watchOS)
      public var body: some View {
        D2SDebugLabel("[DM]") {
          Text(stringValue)
        }
      }
    #else // not watchOS
      private var url: URL? {
        // Needs `LSApplicationQueriesSchemes`
        guard let v = propertyValue else { return nil }
        let s = object.coerceValueToString(v, formatter: nil, forKey: propertyKey)
        guard !s.isEmpty else { return nil }
        return URL(string: "mailto:" + s)
      }
    
      private func openMail() {
        guard let url = url else { return }
        
        #if os(macOS)
          NSWorkspace.shared.open(url)
        #elseif os(iOS)
          // For this to work, the Info.plist must have "mailto"
          // in the `LSApplicationQueriesSchemes` property.
          if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
          }
        #endif
      }
    
      public var body: some View {
        D2SDebugLabel("[DM]") {
          Text(stringValue)
            .onTapGesture(perform: self.openMail)
        }
      }
    #endif // not watchOS
  }
}
