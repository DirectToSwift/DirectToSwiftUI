//
//  D2SDisplayProperties.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * A ForEach over the `displayPropertyKeys`.
 */
public struct D2SDisplayProperties: View {
  
  @Environment(\.displayPropertyKeys) private var displayPropertyKeys
  
  public var body: some View {
    ForEach(displayPropertyKeys, id: \String.self) { propertyKey in
      PropertySwitch()
        .environment(\.propertyKey, propertyKey)
    }
  }

  private struct PropertySwitch: View {
    @Environment(\.rowComponent) var body
  }
}
