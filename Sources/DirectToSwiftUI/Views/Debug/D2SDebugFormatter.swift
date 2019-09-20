//
//  D2SDebugFormatter.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import Foundation

fileprivate var counter = 0

public class D2SDebugFormatter: Formatter {
  
  public let wrapped: Formatter
  
  override public var description: String {
    "<Debug: \(wrapped)>"
  }
  
  public init(_ formatter: Formatter) {
    counter += 1
    self.wrapped = formatter
    globalD2SLogger.log("\(counter) wrapping:", formatter)
    super.init()
  }
  required init?(coder: NSCoder) {
    fatalError("\(#function) has not been implemented")
  }
  
  open override func string(for obj: Any?) -> String? {
    let s = wrapped.string(for: obj)
    if let s = s {
      globalD2SLogger.log("\(counter) stringForObj:", obj, "=>", s)
    }
    else {
      globalD2SLogger.log("\(counter) stringForObj:", obj, "=> NIL")
    }
    return s
  }

  
  open override
  func attributedString(for obj: Any,
                        withDefaultAttributes
                          attrs: [NSAttributedString.Key : Any]?)
       -> NSAttributedString?
  {
    let s = wrapped.attributedString(for: obj, withDefaultAttributes: attrs)
    if let s = s {
      globalD2SLogger.log("\(counter) asForObj:", obj, "=>", s)
    }
    else {
      globalD2SLogger.log("\(counter) asForObj:", obj, "=> NIL")
    }
    return s
  }

  
  open override func editingString(for obj: Any) -> String? {
    let s = wrapped.editingString(for: obj)
    if let s = s {
      globalD2SLogger.log("\(counter) edstringForObj:", obj, "=>", s)
    }
    else {
      globalD2SLogger.log("\(counter) edstringForObj:", obj, "=> NIL")
    }
    return s
  }
  
  open override
  func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                      for s: String,
                      errorDescription
                        error: AutoreleasingUnsafeMutablePointer<NSString?>?)
       -> Bool
  {
    var e  : NSString?
    var o  : AnyObject?
    let ok = wrapped.getObjectValue(&o, for: s, errorDescription: &e)
    obj?  .pointee = o
    error?.pointee = e
    if let o = o {
      globalD2SLogger.log("\(counter) valueForString:", s, "=>", o)
    }
    else if let e = e {
      globalD2SLogger.log("\(counter) valueForString:", s, "error:", e)
    }
    else {
      globalD2SLogger.log("\(counter) valueForString:", s, "=> NIL")
    }
    return ok
  }
 
  open override
  func isPartialStringValid(
    _ partialStringPtr: AutoreleasingUnsafeMutablePointer<NSString>,
    proposedSelectedRange proposedSelRangePtr: NSRangePointer?,
    originalString origString: String,
    originalSelectedRange origSelRange: NSRange,
    errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?)
    -> Bool
  {
    var e  : NSString?
    let ok = wrapped.isPartialStringValid(
      partialStringPtr, proposedSelectedRange: proposedSelRangePtr,
      originalString: origString, originalSelectedRange: origSelRange,
      errorDescription: &e
    )
    error?.pointee = e
    if ok {
      globalD2SLogger.log("\(counter) p-valid:", origString)
    }
    else if let e = e {
      globalD2SLogger.log("\(counter) p-INvalid:", origString, e)
    }
    else {
      globalD2SLogger.log("\(counter) p-INvalid:", origString)
    }
    return ok
  }
}
