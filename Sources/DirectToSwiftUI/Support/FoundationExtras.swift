//
//  FoundationExtras.swift
//  Direct to SwiftUI
//
//  Copyright © 2017-2019 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.CharacterSet

enum UObject {
  static func boolValue(_ v: Any?, default: Bool = false) -> Bool {
    guard let v = v else { return `default` }
    if let b = v as? Bool { return b }
    if let i = v as? Int  { return i != 0 }
    let s = ((v as? String) ?? String(describing: v)).lowercased()
    return s == "true" || s == "yes" || s == "1"
  }
}

extension String {
  
  var isMixedCase : Bool {
    guard !isEmpty else { return false }
    let upper = CharacterSet.uppercaseLetters
    let lower = CharacterSet.lowercaseLetters
    
    var hadUpper = false
    var hadLower = false
    for c in self.unicodeScalars {
      if upper.contains(c) {
        if hadLower { return true }
        hadUpper = true
      }
      else if lower.contains(c) {
        if hadUpper { return true }
        hadLower = true
      }
    }
    return false
  }
}

extension String {
  
  var capitalizedWithPreUpperSpace: String {
    guard !isEmpty else { return "" }
    
    var s = ""
    s.reserveCapacity(count)
    
    var wasLastUpper = false
    var isFirst = true
    for c in self {
      let isUpper = c.isUppercase
      
      if isFirst {
        s += c.uppercased()
        isFirst = false
        wasLastUpper = true
        continue
      }
      
      defer { wasLastUpper = isUpper }

      if isUpper {
        if !wasLastUpper { s += " " }
      }
      s += String(c)
    }
    
    return s
  }
  
}

extension String {
  
  func range(of needle: String, skippingQuotes quotes: CharacterSet,
             escapeUsing escape: Character) -> Range<Index>?
  {
    // Note: stupid port of GETobjects version
    // TODO: speed ...
    // TODO: check correctness with invalid input !
    guard !needle.isEmpty else { return nil }
    if quotes.isEmpty {
      return needle.range(of: needle)
    }

    let slen = needle.count
    let sc   = needle.first!

    var i = startIndex
    while i < endIndex {
      let c = self[i]
      defer { i = index(after: i) }
      
      if c == sc {
        if slen == 1 { return i..<(index(after: i)) }
        if self[i..<endIndex].hasPrefix(needle) {
          return i..<(index(i, offsetBy: slen))
        }
      }
      else if let s = c.unicodeScalars.first, quotes.contains(s) {
        /* skip quotes */
        i = index(after: i)
        while i < endIndex && self[i] != c {
          defer { i = index(after: i) }

          if self[i] == escape {
            i = index(after: i) /* skip next char (eg \') */
          }
        }
      }
    }
    return nil
  }
}

import class Foundation.DateComponentsFormatter
import class Foundation.NSCalendar

public extension DateComponentsFormatter {
  // Yes, yes. ABI and such.
  
  convenience init(unitsStyle             : UnitsStyle? = nil,
                   allowedUnits           : NSCalendar.Unit? = nil,
                   zeroFormattingBehavior : ZeroFormattingBehavior? = nil)
  {
    self.init()
    if let v = unitsStyle             { self.unitsStyle             = v }
    if let v = allowedUnits           { self.allowedUnits           = v }
    if let v = zeroFormattingBehavior { self.zeroFormattingBehavior = v }
  }
}
