//
//  D2SEditDate.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import struct ZeeQL.KeyValueCoding

public extension BasicLook.Property.Edit {
  
  struct Date: View, D2SAttributeValidator {
    // Note: When used inside a Form, the DatePicker (and presumably other
    //       pickers on iOS) uses multiple List rows.
    //       Aka the Form is a List itself, so we can't nest it in another.
    //       (which is a little weird, it should just expand its own cell).
    
    typealias String = Swift.String
    typealias Bool   = Swift.Bool
    typealias Date   = Foundation.Date
    
    public init() {}
    
    @EnvironmentObject public var object : OActiveRecord
    
    @Environment(\.propertyKey)            private var propertyKey
    @Environment(\.propertyValue)          private var propertyValue
    @Environment(\.attribute)              public  var attribute
    @Environment(\.displayNameForProperty) private var label

    private var isOptional : Bool { attribute.allowsNull ?? true }
    
    private var isNull : Bool {
      !(propertyValue is Date)
    }
    
    private func setNull(_ wantsValue: Bool) {
      if wantsValue {
        let storedDate = object.snapshot?[propertyKey] as? Date
        object.nonFailingTakeValue(storedDate ?? Date(), forKeyPath: propertyKey)
      }
      else {
        object.nonFailingTakeValue(nil, forKeyPath: propertyKey)
      }
    }
    
    #if os(iOS) // use non-Form DatePicker on iOS
      public var body: some View {
        D2SDebugLabel("[ED\(isOptional ? "?" : "")]") {
          if isOptional {
            ListEnabledDatePicker(label, selection: object.dateBinding(propertyKey))
            Toggle(isOn: Binding(get: { self.isNull }, set: self.setNull)) {
              Text("") // TBD
            }
          }
          else {
            ListEnabledDatePicker(label, selection: object.dateBinding(propertyKey))
          }
        }
      }
    #elseif os(watchOS)
      public var body: some View {
        D2SDebugLabel("[ED\(isOptional ? "?" : "")]") {
          Text("FIXME") // no DatePicker on watchOS b7
        }
      }
    #else // regular datepicker on others
      public var body: some View {
        D2SDebugLabel("[ED\(isOptional ? "?" : "")]") {
          if isOptional {
            DatePicker(label, selection: object.dateBinding(propertyKey))
            Toggle(isOn: Binding(get: { self.isNull }, set: self.setNull)) {
              Text("") // TBD
            }
          }
          else {
            DatePicker(label, selection: object.dateBinding(propertyKey))
          }
        }
      }
    #endif
  }
}
