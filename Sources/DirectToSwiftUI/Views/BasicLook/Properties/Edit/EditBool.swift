//
//  D2SEditBool.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import struct ZeeQL.KeyValueCoding

public extension BasicLook.Property.Edit {
  
  struct Bool: View, D2SAttributeValidator {

    typealias String = Swift.String
    typealias Bool   = Swift.Bool
    
    public init() {}
    
    @EnvironmentObject public var object : OActiveRecord
    
    @Environment(\.propertyKey)   private var propertyKey
    @Environment(\.propertyValue) private var propertyValue
    @Environment(\.attribute)     public  var attribute

    private var boolValue : Bool {
      return UObject.boolValue(propertyValue, default: false)
    }
    private var stringValue: String {
      return boolValue ? "✓" : "⨯"
    }

    public var body: some View {
      // FIXME: use toggle
      D2SDebugLabel("[EB]") {
        HStack {
          D2SEditPropertyName(isValid: isValid)
          Spacer()
          Toggle(isOn: object.boolBinding(propertyKey)) { EmptyView() }
        }
      }
    }
  }
}
