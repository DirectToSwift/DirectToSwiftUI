//
//  D2SEditString.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import struct ZeeQL.KeyValueCoding

public extension BasicLook.Property.Edit {
  
  struct String: View {

    typealias String = Swift.String
    typealias Bool   = Swift.Bool
    typealias Date   = Foundation.Date

    public init() {}
    
    @EnvironmentObject var object : OActiveRecord
    
    @Environment(\.propertyKey)            private var propertyKey
    @Environment(\.formatter)              private var formatter
    @Environment(\.displayNameForProperty) private var label

    private struct Labeled<V: View>: View, D2SAttributeValidator {
      
      @ObservedObject var object : OActiveRecord
      
      @Environment(\.displayNameForProperty) private var label
      @Environment(\.attribute)              var attribute

      let content : V

      var body: some View {
        VStack(alignment: .leading) {
          D2SPropertyNameHeadline(isValid: isValid)
          content
        }
      }
    }

    public var body: some View {
      Group {
        if formatter != nil {
          D2SDebugLabel("[ESF]") {
            Labeled(object: object, content:
              TextField("", text: object.binding(propertyKey)
                                        .format(with: formatter!)))
          }
        }
        else {
          D2SDebugLabel("[ES]") {
            Labeled(object: object, content:
              TextField("", text: object.stringBinding(propertyKey)))
          }
        }
      }
    }
  }
}
