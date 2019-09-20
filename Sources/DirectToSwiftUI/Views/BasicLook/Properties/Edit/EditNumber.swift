//
//  D2SEditNumber.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import Foundation
import SwiftUI
import struct ZeeQL.KeyValueCoding

public extension BasicLook.Property.Edit {
  
  struct Number: View, D2SAttributeValidator {

    public init() {}
    
    @EnvironmentObject public var object : OActiveRecord
    
    @Environment(\.propertyKey) private var propertyKey
    @Environment(\.formatter)   private var formatter
    @Environment(\.attribute)   public  var attribute

    // E.g. configure for Double etc
    private static let formatter : NumberFormatter = {
      let f = NumberFormatter()
      f.allowsFloats = false
      return f
    }()
    
    private var formatterToUse: Formatter {
      return formatter ?? Number.formatter
    }

    public var body: some View {
      // b7 `formatter` init of TextField does not work properly.
      D2SDebugLabel("[EN]") {
        HStack {
          D2SEditPropertyName(isValid: isValid)
          Spacer()
          TextField("", text: object.binding(propertyKey)
                                    .format(with: formatterToUse))
            .multilineTextAlignment(.trailing)
        }
      }
    }
  }
}
