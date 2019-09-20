//
//  D2SDisplayPropertyViews.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import struct ZeeQL.KeyValueCoding

public extension BasicLook.Property.Display {
  
  /**
   * Displays the value of a bool property.
   */
  struct Bool: View {

    typealias String = Swift.String
    typealias Bool   = Swift.Bool

    public init() {}
    
    @EnvironmentObject var object : OActiveRecord
    
    @Environment(\.propertyValue) private var propertyValue

    private var boolValue : Bool {
      return UObject.boolValue(propertyValue, default: false)
    }
    private var stringValue: String {
      return boolValue ? "✓" : "⨯"
    }

    public var body: some View {
      D2SDebugLabel("[DB]") {
        Text(stringValue)
      }
    }
  }
}
