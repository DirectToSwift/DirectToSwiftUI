//
//  FormatterBinding.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import class  Foundation.Formatter
import class  Foundation.NSString
import struct SwiftUI.Binding

public extension Binding {
  
  /**
   * Creates a String binding from an arbitrary value binding which pipes the
   * value binding through a formatter.
   *
   * This is a workaround to fix the `TextField` not doing the same when a
   * formatter is attached.
   */
  func format(with formatter: Formatter, editing: Bool = true)
       -> Binding<String>
  {
    Binding<String>(
      get: {
        if editing {
          guard let s = formatter.editingString(for: self.wrappedValue) else {
            globalD2SLogger.trace("could not format:", self.wrappedValue,
                                  "\n  using:", formatter,
                                  "\n  to string.")
            return ""
          }
          return s
        }
        else {
          guard let s = formatter.string(for: self.wrappedValue) else {
            globalD2SLogger.trace("could not format:", self.wrappedValue,
                                  "\n  using:", formatter,
                                  "\n  to string.")
            return ""
          }
          return s
        }
      },
      set: { string in
        var value : AnyObject? = nil
        var error : NSString?  = nil
        guard formatter.getObjectValue(&value, for: string,
                                       errorDescription: &error) else {
          globalD2SLogger.warn("could not format:", string,
                               "\n  using:", formatter,
                               "\n  to:   ", Value.self)
          return
        }
        guard let typedValue = value as? Value else {
          globalD2SLogger.warn("could not format:", string,
                               "\n  value:", value,
                               "\n  using:", formatter,
                               "\n  to:   ", Value.self)
          return
        }
        self.wrappedValue = typedValue
      }
    )
  }
}
