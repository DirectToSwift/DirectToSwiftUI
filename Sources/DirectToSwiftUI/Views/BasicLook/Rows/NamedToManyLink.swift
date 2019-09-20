//
//  D2SToManyLinkRow.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import ZeeQL

public extension BasicLook.Row {

  /**
   * This provides a row which serves as a link to follow the toMany
   * relationship.
   */
  struct NamedToManyLink: View {
    
    @Environment(\.object)                 private var object
    @Environment(\.displayNameForProperty) private var label
    @Environment(\.relationship)           private var relationship
    
    private var targetEntityName: String {
      relationship.destinationEntity?.name ?? ""
    }
    
    private var relationshipQualifier : ZeeQL.Qualifier? {
      // Note: We could also attempt to lookup the inverse relationship and use
      //       that, but we don't really know whether the `Model` has that
      //       defined.
      // TBD: why is it ambiguous w/o the `as DatabaseObject`? (Xcode 11GM2)
      relationship.qualifierInDestinationForSource(object as DatabaseObject)
    }
    
    public var body: some View {
      D2SNavigationLink(destination:
        D2SPageView()
          .environment(\.auxiliaryQualifier, relationshipQualifier)
          .environment(\.entity, relationship.destinationEntity!)
          .task(.list)
          .ruleObject(D2SKeys.object.defaultValue))
      {
        Text(label)
      }
    }
  }
}
