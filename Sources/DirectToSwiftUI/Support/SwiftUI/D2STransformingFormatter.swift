//
//  D2STransformingFormatter.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import class Foundation.Formatter
import class Foundation.NSCoder
import class Foundation.NSString

/**
 * This one pipes the value to be formatted through a closure before passing it
 * on to another formatter.
 *
 * This is useful if the other formatter expects the value as a specific type
 * and/or unit.
 *
 * Example:
 *
 *     let minuteDurationFormatter: Formatter = {
 *       let mf : DateComponentsFormatter = {
 *         let f = DateComponentsFormatter()
 *         f.allowedUnits = [ .hour, .minute ]
 *         f.unitsStyle = .short
 *         return f
 *       }()
 *       return D2STransformingFormatter(mf) { ( minutes : Int ) in
 *         TimeInterval(minutes * 60)
 *       }
 *     }()
 *     
 */
public final class D2STransformingFormatter<In, Out>: Formatter {
  
  let wrapped : Formatter
  let string  : ( In ) -> Out
  let value   : ( ( Out ) -> In )?
  
  public init(_ wrapped: Formatter, string: @escaping ( In ) -> Out) {
    self.wrapped = wrapped
    self.string  = string
    self.value   = nil
    super.init()
  }
  required init?(coder: NSCoder) {
    fatalError("\(#function) has not been implemented")
  }

  override public func string(for obj: Any?) -> String? {
    guard let inValue = obj as? In else {
      return wrapped.string(for: obj as? Out)
    }
    return wrapped.string(for: string(inValue))
  }
  
  override public func editingString(for obj: Any) -> String? {
    return string(for: obj)
  }
  
  override public
  func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                      for string: String, errorDescription
                        error: AutoreleasingUnsafeMutablePointer<NSString?>?)
       -> Bool
  {
    var o : AnyObject? = nil
    let ok = wrapped.getObjectValue(&o, for: string, errorDescription: error)
    guard ok, let out = o as? Out else {
      obj?.pointee = nil
      return false
    }
    
    if let value = value {
      obj?.pointee = value(out) as AnyObject
      return true
    }
    else if let i = out as? In {
      obj?.pointee = i as AnyObject
      return true
    }
    else {
      obj?.pointee = o
      return false
    }
  }
}
