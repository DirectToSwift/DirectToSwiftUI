//
//  StringProperty.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import struct ZeeQL.KeyValueCoding

public extension BasicLook.Property.Display {

  struct String: View {

    typealias String = Swift.String

    public init() {}

    @EnvironmentObject private var object : OActiveRecord
    
    @Environment(\.propertyKey)         private var propertyKey
    @Environment(\.propertyValue)       private var propertyValue
    @Environment(\.formatter)           private var formatter
    @Environment(\.displayStringForNil) private var stringForNil
    @Environment(\.debug)               private var debug

    private var stringValue: String {
      guard let v = propertyValue else { return stringForNil }
      return object.coerceValueToString(v, formatter: formatter,
                                        forKey: propertyKey)
    }

    public var body: some View {
      D2SDebugLabel("[DS]") { Text(stringValue) }
    }
  }
}
