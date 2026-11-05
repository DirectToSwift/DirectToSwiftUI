//
//  D2SEntityMasterDetailPage.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension BasicLook.PageWrapper.MasterDetail {

  /**
   * Shows the entities in a sidebar and the list of the selected one next to it.
   *
   * Note: This is only intended for macOS.
   */
  struct EntityMasterDetailPage: View {

    @Environment(\.model) private var model
    @State private var selectedEntityName : String?

    private var selectedEntity: Entity? {
      guard let entityName = selectedEntityName else { return nil }
      guard let entity = model[entity: entityName] else {
        #if os(macOS)
          globalD2SLogger.error("did not find entity:", entityName,
                                "in:", model)
          return nil
        #else
          fatalError("did not find entity: \(entityName) in \(model)")
        #endif
      }
      return entity
    }
    
    struct EntityContent: View {

      @Environment(\.entity) private var entity
      
      var body: some View {
        D2SPageView()
          .environment(\.entity, entity)
          .task("list")
      }
    }
    
    struct EmptyContent: View {
      // FIXME: Show something useful as the default, maybe a query page
      var body: some View {
        Text("Select an Entity")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    
    @ViewBuilder private var detail: some View {
      if selectedEntityName == nil {
        EmptyContent()
      }
      else {
        EntityContent()
          .environment(\.entity,
                       selectedEntity ?? D2SKeys.entity.defaultValue)
          .id(selectedEntityName)
      }
    }

    // TODO: Async login page
    #if os(macOS)
      public var body: some View {
        NavigationSplitView {
          Sidebar(selectedEntityName: $selectedEntityName)
            .task(.query)
            .navigationSplitViewColumnWidth(min: 160, ideal: 200, max: 300)
        } detail: {
          detail
            .frame(minWidth: 400 as CGFloat)
        }
      }
    #else
      public var body: some View {
        HStack(spacing: 0 as CGFloat) {
          Sidebar(selectedEntityName: $selectedEntityName)
            .task(.query)
            .frame(minWidth: 120 as CGFloat, maxWidth: 200 as CGFloat)
          
          detail
            .frame(minWidth: 400 as CGFloat, idealWidth: 600 as CGFloat,
                   maxWidth: .infinity)
        }
      }
    #endif
  }
}
