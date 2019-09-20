//
//  D2SDebugEntityInfo.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public struct D2SDebugEntityInfo: View {
  
  @Environment(\.entity) var entity

  public var body: some View {
    D2SDebugBox {
      if entity.d2s.isDefault {
        Text("No Entity set")
      }
      else {
        Text(verbatim: entity.displayNameWithExternalName)
          .font(.title)
        Text(verbatim: "\(entity)")
          .lineLimit(3)
        
        Text("#\(entity.attributes.count) attributes")
        Text("#\(entity.relationships.count) relationships")
      }
    }
    .lineLimit(1)
  }
}
