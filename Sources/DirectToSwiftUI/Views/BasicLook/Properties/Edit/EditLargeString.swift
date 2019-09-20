//
//  D2SEditLargeString.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import struct ZeeQL.KeyValueCoding

public extension BasicLook.Property.Edit {
  
  /**
   * Edit long strings ...
   */
  struct LargeString: View, D2SAttributeValidator {

    typealias String = Swift.String
    typealias Bool   = Swift.Bool
    
    public init() {}
    
    @EnvironmentObject public var object : OActiveRecord
    
    @Environment(\.propertyKey)            private var propertyKey
    @Environment(\.displayNameForProperty) private var label
    @Environment(\.attribute)              public  var attribute

    #if os(iOS) // use UIView, NSView is prepared, needs testing.
      public var body: some View {
        Group {
          D2SDebugLabel("[ELS]") {
            MultilineEditor(text: object.stringBinding(propertyKey))
              .frame(height: (UIFont.systemFontSize * 1.2) * 3)
          }
        }
      }
    #else
      public var body: some View {
        Group {
          D2SDebugLabel("[ELS]") {
            TextField(label, text: object.stringBinding(propertyKey))
              //.lineLimit(5) // Doesn't actually work
              .multilineTextAlignment(.leading)
              //.frame(minHeight: 100) // doesn't help, still wrapps inside
          }
        }
      }
    #endif
  }
}
