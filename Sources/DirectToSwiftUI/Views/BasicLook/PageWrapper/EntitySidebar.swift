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
    
    private func colorForEntityName(_ name: String) -> Color {
      /* looks wrong on macOS:
       .background(self.selectedEntityName == name
          ? Color(NSColor.selectedContentBackgroundColor) : nil)
      */
      // hence our non-standard highlighting
      #if os(macOS)
        return selectedEntityName == name
          ? Color(NSColor.selectedTextColor)
          : Color(NSColor.secondaryLabelColor)
      #elseif os(iOS)
        return selectedEntityName == name
          ? Color(UIColor.label)
          : Color(UIColor.secondaryLabel)
      #else
        return selectedEntityName == name
          ? Color.black
          : Color.gray
      #endif
    }
    
    public var body: some View {
      Group {
      #if false
        // This is now almost right. but the 1st item does not select in b7
        List(names, id: \String.self, selection: $selectedEntityName) { name in
          Group {
            EntityName()
              .tag(name)
          }
          .environment(\.entity, { self.model[entity: name]! }())
        }
        .listStyle(SidebarListStyle()) // requires Section
      #elseif os(macOS)
        List { // works but wrong color: (selection: $selectedEntityName) {
          Section(header: Text("Entities")) { // this is required for sidebar!
            ForEach(names, id: \String.self) { name in
              HStack {
                EntityName()
                Spacer()
              }
              .environment(\.entity, {
                self.model[entity: name] ?? D2SKeys.entity.defaultValue
              }())
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .foregroundColor(self.colorForEntityName(name))
              .onTapGesture {
                self.selectedEntityName = name
              }
              .tag(name)
            }
          }
          .collapsible(false)
        }
        .listStyle(SidebarListStyle()) // requires Section
      #elseif os(macOS)
        List {
          ForEach(names, id: \String.self) { name in
            HStack {
              EntityName()
              Spacer()
            }
            .environment(\.entity, { self.model[entity: name]! }())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(self.colorForEntityName(name))
            .onTapGesture {
              self.selectedEntityName = name
            }
            .tag(name)
          }
        }
        .listStyle(SidebarListStyle()) // requires Section
      #elseif os(macOS)
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
          .collapsible(false)
        }
        // macOS only:
        // .listStyle(SidebarListStyle()) // requires Section
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
