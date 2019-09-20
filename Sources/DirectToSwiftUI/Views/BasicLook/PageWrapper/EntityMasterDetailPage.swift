//
//  D2SEntityMasterDetailPage.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension BasicLook.PageWrapper.MasterDetail {

  /**
   * NavigationView really works badly on macOS. This is kinda like a replacement
   * but lacks the split view ...
   *
   * Note: This is only intended for macOS.
   */
  struct EntityMasterDetailPage: View {

    @Environment(\.model) private var model
    @State private var selectedEntityName : String?

    private var selectedEntity: Entity? {
      guard let entityName = selectedEntityName else { return nil }
      guard let entity = model[entity: entityName] else {
        fatalError("did not find entity: \(entityName) in \(model)")
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
    
    private var backgroundColor: Color? {
      #if os(macOS)
        return Color(NSColor.textBackgroundColor)
      #else
        return nil
      #endif
    }

    // FIXME: show navbar title?
    // TODO: Async login page
    public var body: some View {
      HStack(spacing: 0 as CGFloat) {
        //HSplitView { // this works, but we get a window title bar again
        
        Sidebar(selectedEntityName: $selectedEntityName)
          .task(.query)
          .frame(minWidth: 120 as CGFloat, maxWidth: 200 as CGFloat)
        
        Group {
          if selectedEntityName == nil {
            EmptyContent()
          }
          else {
            EntityContent()
              .environment(\.entity, selectedEntity!)
          }
        }
        .frame(minWidth: 400 as CGFloat, idealWidth: 600 as CGFloat,
               maxWidth: .infinity)
        .background(self.backgroundColor)
      }
    }
  }
}
