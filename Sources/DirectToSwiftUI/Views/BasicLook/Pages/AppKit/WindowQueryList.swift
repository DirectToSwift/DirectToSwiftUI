//
//  WindowQueryList.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import class ZeeQLCombine.OActiveRecord
import class ZeeQLCombine.ActiveDataSource

public extension BasicLook.Page.AppKit {
  
#if !os(macOS)
  static func WindowQueryList() -> some View {
    Text("\(#function) is not available on this platform")
  }
#else

  /**
   * Shows a page containing the contents of an entity.
   *
   * Backed by a D2SDisplayGroup.
   *
   * This variant is opening windows for actions. Intended for macOS.
   */
  struct WindowQueryList: View {
    
    @Environment(\.database)            private var database
    @Environment(\.entity)              private var entity
    @Environment(\.auxiliaryQualifier)  private var auxiliaryQualifier
    @Environment(\.displayPropertyKeys) private var displayPropertyKeys
    
    public init() {}

    private func makeDataSource() -> ActiveDataSource<OActiveRecord> {
      return ActiveDataSource(database: database, entity: entity)
    }
    
    public var body: some View {
      Bound(dataSource: makeDataSource(), auxiliaryQualifier: auxiliaryQualifier,
            displayPropertyKeys: displayPropertyKeys)
        .environment(\.auxiliaryQualifier, nil) // reset!
    }

    struct Bound<Object: OActiveRecord>: View {
      
      @Environment(\.ruleContext)           private var context
      @Environment(\.isEntityReadOnly)      private var isReadOnly
      @Environment(\.title)                 private var title
      @Environment(\.displayNameForEntity)  private var entityTitle
      @Environment(\.nextTask)              private var nextTask
      @Environment(\.initialPropertyValues) private var initialPropertyValues
      @Environment(\.creationTimestampPropertyKey) private var createTS
      
      // This seems to crash on macOS b7
      @ObservedObject private var displayGroup : D2SDisplayGroup<Object>
      
      private var entity: Entity { displayGroup.dataSource.entity! }
      
      init(dataSource: ActiveDataSource<Object>, auxiliaryQualifier: Qualifier?,
           displayPropertyKeys: [ String ])
      {
        self.displayGroup = D2SDisplayGroup(
          dataSource: dataSource,
          auxiliaryQualifier: auxiliaryQualifier,
          displayPropertyKeys: displayPropertyKeys
        )
      }
      
      private func openWindow(for object: OActiveRecord, task: String,
                              title: String)
      {
        let view = D2SPageView()
          .task(task)
          .ruleObject(object)
          .ruleContext(context)

        let wc = D2SInspectWindow(rootView: view)
        wc.window?.title = title
        wc.window?.setFrameAutosaveName("Inspect:\(title)")
        wc.showWindow(nil)
      }
      
      func handleDoubleTap(on object: OActiveRecord?) {
        guard let object = object else { return } // still a fault
        openWindow(for: object, task: nextTask, title: title)
      }
      
      private func makeNewRecord() -> OActiveRecord {
        let object = displayGroup.dataSource.createObject()
        for ( k, v ) in initialPropertyValues {
          try? KeyValueCoding.takeValue(v, forKeyPath: k, inObject: object)
        }
        
        if let pkey = createTS {
          try? KeyValueCoding.takeValue(Date(), forKey: pkey, inObject: object)
        }
        
        return object
      }
      
      private func addRecord() {
        openWindow(for: makeNewRecord(), task: "edit",
                   title: "New \(entityTitle)")
      }
      
      private var sortAttributes: [ Attribute ] {
        entity.d2s.defaultSortPropertyKeys.compactMap { entity[attribute: $0] }
      }
    
      var body: some View {
        List(displayGroup.results) { fault in
          Group {
            if fault.accessingFault() { D2SRowFault() }
            else {
              HStack {
                D2STitledSummaryView() // TODO: select via rule!
                  .frame(maxWidth: .infinity)
                  .ruleObject(fault.object)
                  .ruleContext(self.context) // req on macOS
              }
            }
          }
          .contentShape(Rectangle())
          .onTapGesture(count: 2) { // this looses the D2SCtx!
            self.handleDoubleTap(on: fault.isFault ? nil : fault.object)
          }
        }
        .searchable(text: $displayGroup.queryString, placement: .toolbar)
        .navigationTitle(entityTitle)
        .toolbar {
          ToolbarItemGroup {
            Button(action: { self.displayGroup.reload() }) {
              Label("Reload", systemImage: "arrow.clockwise")
            }
            Menu {
              ForEach(sortAttributes, id: \.name) { attribute in
                Button(attribute.name.capitalizedWithPreUpperSpace) {
                  self.displayGroup.sortAttribute = attribute
                }
              }
              Divider()
              Button("Default") { self.displayGroup.sortAttribute = nil }
            } label: {
              Label("Sort", systemImage: "arrow.up.arrow.down")
            }
            if !isReadOnly {
              Button(action: self.addRecord) {
                Label("Add", systemImage: "plus")
              }
            }
          }
        }
      }
    }
  }
#endif // macOS
}
