//
//  EntityList.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public extension BasicLook.Page {

  /**
   * Shows a list of entities w/ a navigation link.
   */
  struct EntityList: View {
    
    @Environment(\.model)              private var model
    @Environment(\.visibleEntityNames) private var names
    
    struct EntityName: View {
      @Environment(\.displayNameForEntity) private var title
      var body: some View { Text(title) }
    }
    
    struct Cell: View {
      
      @Environment(\.nextTask) private var nextTask
      
      let name : String
      var body : some View {
        D2SNavigationLink(destination: D2SEntityPageView(entityName: name)
                                         .task(nextTask))
        {
          EntityName()
        }
      }
    }

    #if os(macOS) // macOS needs the section header in the sidebar style
      #if true
        public var body: some View {
          List { // (selection: $selection) {
            Section(header: Text("Entities")) { // header is req for sidebar b6!
              ForEach(names, id: \String.self) { name in
                Cell(name: name)
                  .environment(\.entity, self.entity(for: name))
              }
            }
            .collapsible(false)
          }
          .listStyle(SidebarListStyle()) // requires Section
        }
      #else // this kinda tracks a selection, but still doesn't work
        @State var selection: String?
      
        public var body: some View {
          List(names, id: \String.self, selection: $selection) { name in
            Section {
              Cell(name: name)
            }
            .environment(\.entity, self.entity(for: name))
          }
        }
      #endif
    #else // not macOS
      @Environment(\.debugComponent) private var debugComponent

      public var body: some View {
        VStack {
          List(names, id: \String.self) { name in
            Cell(name: name)
              .environment(\.entity, self.entity(for: name))
          }
          debugComponent
        }
      }
    #endif
    
    private func entity(for name: String) -> Entity {
      guard let entity = self.model[entity: name] else {
        #if false
          globalD2SLogger.warn("did not find entity:", name, "\n  in:", model)
        #endif
        return D2SKeys.entity.defaultValue
      }
      return entity
    }
  }
}
