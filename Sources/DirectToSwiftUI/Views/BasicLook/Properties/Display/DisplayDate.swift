//
//  DateProperty.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import struct Foundation.Date

public extension BasicLook.Property.Display {
  
  struct Date: View {
    
    typealias String = Swift.String
    typealias Date   = Foundation.Date

    public init() {}

    @EnvironmentObject var object : OActiveRecord
    
    @Environment(\.attribute)           private var attribute
    @Environment(\.propertyValue)       private var propertyValue
    @Environment(\.displayStringForNil) private var stringForNil

    private var stringValue: String {
      guard let v = propertyValue else { return stringForNil }
      
      if let date = v as? Date {
        return attribute.dateFormatter().string(from: date)
      }
      
      if let s = v as? String { return s }
      
      return String(describing: v)
    }

    public var body: some View {
      D2SDebugLabel("[DD]") { Text(stringValue) }
    }
    
  }
}
