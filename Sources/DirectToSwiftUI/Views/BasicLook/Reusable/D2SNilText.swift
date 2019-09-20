//
//  D2SNilText.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * Shows the `\.title` stored in the environment.
 */
public struct D2SNilText: View {
  
  @Environment(\.displayStringForNil) private var displayStringForNil

  public var body: some View { Text(verbatim: displayStringForNil) }
}
