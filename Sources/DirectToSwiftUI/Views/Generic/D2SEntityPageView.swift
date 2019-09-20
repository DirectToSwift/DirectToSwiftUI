//
//  D2SEntityPageView.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import protocol ZeeQL.Entity
import class    ZeeQL.Model

/**
 * Show the View which the `page` key yields, but inject the `entity` for the
 * provided `name` first.
 */
public struct D2SEntityPageView: View {
  
  @Environment(\.model) private var model
  
  public let entityName : String

  var entity: Entity {
    guard let entity = model[entity: entityName] else {
      fatalError("did not find entity: \(entityName) in \(model)")
    }
    return entity
  }
  
  public var body: some View {
    D2SPageView()
      .environment(\.entity, entity)
  }
}
