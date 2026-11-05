//
//  D2SEntityListSidebar.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension BasicLook.PageWrapper.MasterDetail.EntityMasterDetailPage {

  /**
   * A sidebar listing the entities for the D2SEntityMasterDetailPage.
   *
   * Primarily intended for macOS.
   */
  struct Sidebar: View {

    @Binding public var selectedEntityName : String?
             public let autoselect         = true

    @Environment(\.model)              private var model
    @Environment(\.visibleEntityNames) private var names
    
    struct EntityName: View {
      @Environment(\.displayNameForEntity) private var title
      var body: some View { Text(title) }
    }
    
    public var body: some View {
      Group {
      #if os(macOS)
        List(selection: $selectedEntityName) {
          Section("Entities") {
            ForEach(names, id: \String.self) { name in
              EntityName()
                .environment(\.entity, {
                  self.model[entity: name] ?? D2SKeys.entity.defaultValue
                }())
                .tag(name)
            }
          }
        }
        .listStyle(.sidebar)
      #else // currently use for iOS etc
        List { // (selection: $selection) {
          Section(header: Text("Entities")) { // this is required for sidebar!
            ForEach(names, id: \String.self) { name in
              EntityName()
                .tag(name)
                .onTapGesture {
                  self.selectedEntityName = name
                }
            }
          }
        }
        // macOS only:
        // .listStyle(SidebarListStyle()) // requires Section
      #endif
      }
      .onAppear {
        if self.autoselect && self.selectedEntityName == nil {
          self.selectedEntityName = self.names.first
        }
      }
    }
  }
}
