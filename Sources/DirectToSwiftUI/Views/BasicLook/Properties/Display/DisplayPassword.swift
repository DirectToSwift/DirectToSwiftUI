//
//  D2SDisplayPassword.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import struct ZeeQL.KeyValueCoding

public extension BasicLook.Property.Display {
  
  /**
   * This just shows a lock or `-` if the password is empty.
   *
   * Guess you wanted to see the actualy password, didn't you? Feel free to
   * provided your own View which can reverse stored hashes using some
   * haxor databases.
   */
  struct Password: View {

    typealias String = Swift.String
    typealias Bool   = Swift.Bool

    public init() {}
    
    @EnvironmentObject var object : OActiveRecord

    @Environment(\.propertyKey)         private var propertyKey
    @Environment(\.propertyValue)       private var propertyValue
    @Environment(\.displayStringForNil) private var stringForNil

    private var hasPassword: Bool {
      guard let v = propertyValue else { return false }
      if let s = v as? String { return !s.isEmpty }
      globalD2SLogger.warn("unexpected type for password field:",
                           type(of: v))
      return !String(describing: v).isEmpty
    }

    public var body: some View {
      if hasPassword { return Text(verbatim: "🔐") }
      else           { return Text(verbatim: stringForNil)}
    }
  }
}
