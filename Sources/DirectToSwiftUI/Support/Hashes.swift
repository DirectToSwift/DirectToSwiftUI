//
//  File.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import CryptoKit
import struct Foundation.Data

public extension String {
  
  func sha1() -> String {
    Insecure.SHA1.hash(data: Data(self.utf8)).hexEncoded
  }
  func md5() -> String {
    Insecure.MD5.hash(data: Data(self.utf8)).hexEncoded
  }
}

extension Sequence where Element == UInt8 {
  
  var hexEncoded : String {
    lazy.map {
      $0 > 15
        ? String($0, radix: 16, uppercase: false)
        : "0" + String($0, radix: 16, uppercase: false)
    }.joined()
  }
}
