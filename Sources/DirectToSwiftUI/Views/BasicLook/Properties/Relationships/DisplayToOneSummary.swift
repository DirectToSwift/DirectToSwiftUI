//
//  D2SDisplaySummary.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension BasicLook.Property.Display {

  /**
   * Fetches a to one relationship of an object and displays the
   * summary for that (using `D2SSummaryView`).
   */
  struct ToOneSummary: View {

    public typealias String = Swift.String

    private let navigationTask : String
      // TBD: maybe make this an environment key (aka `nextTask`?)
    
    public init(navigationTask: String = "inspect") {
      self.navigationTask = navigationTask
    }
    
    public var body: some View {
      D2SToOneLink(navigationTask: navigationTask) {
        D2SSummaryView()
      }
    }
  }
}
