//
//  D2SDisplayToOneTitle.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension BasicLook.Property.Display {
  
  /**
   * Fetches a to one relationship of an object and displays the
   * title for that (using `D2STitleText`).
   */
  struct ToOneTitle: View {

    public typealias String = Swift.String

    private let navigationTask : String
    
    public init(navigationTask: String = "inspect") {
      self.navigationTask = navigationTask
    }
    
    public var body: some View {
      D2SToOneLink(navigationTask: navigationTask) {
        D2STitleText()
      }
    }
  }
}
