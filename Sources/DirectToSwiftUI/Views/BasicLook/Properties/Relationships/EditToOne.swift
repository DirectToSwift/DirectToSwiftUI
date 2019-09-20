//
//  D2SEditToOne.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import struct ZeeQL.KeyValueCoding

public extension BasicLook.Property.Edit {

  struct ToOne: View, D2SRelationshipValidator {
    // Note: Wanted to do this using a "sheet". But FB7270069.
    // So going w/ a navigation link for now.

    public init() {}
    
    @EnvironmentObject public var object : OActiveRecord
    
    @Environment(\.relationship) public var relationship

    public var body: some View {
      D2SNavigationLink(destination:
        // Note: The `object` is still the source object here!
        // Which conflicts w/ the `title` binding.
        D2SPageView()
          .environment(\.entity,             relationship.destinationEntity!)
          .environment(\.relationship,       relationship)
          .environment(\.navigationBarTitle, relationship.name) // TBD: Hm hm
          .ruleObject(object)
          .task(.select)
      )
      {
        VStack(alignment: .leading) {
          D2SPropertyNameHeadline(isValid: isValid)
          D2SToOneContainer {
            RowComponent()
              .task(.select)
          }
        }
      }
    }
    
    private struct RowComponent: View {
      @Environment(\.rowComponent) var body
    }
  }
}
