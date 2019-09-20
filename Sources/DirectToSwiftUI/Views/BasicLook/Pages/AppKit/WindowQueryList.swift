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
    
    @Environment(\.database)           private var database
    @Environment(\.entity)             private var entity
    @Environment(\.auxiliaryQualifier) private var auxiliaryQualifier
    
    public init() {}

    private func makeDataSource() -> ActiveDataSource<OActiveRecord> {
      return ActiveDataSource(database: database, entity: entity)
    }
    
    public var body: some View {
      Bound(dataSource: makeDataSource(), auxiliaryQualifier: auxiliaryQualifier)
        .environment(\.auxiliaryQualifier, nil) // reset!
    }

    struct Bound<Object: OActiveRecord>: View {
      
      @Environment(\.ruleContext)      private var context
      @State                           private var showSortSelector = false
      @Environment(\.isEntityReadOnly) private var isReadOnly
      @Environment(\.title)            private var title
      @Environment(\.nextTask)         private var nextTask
      
      // This seems to crash on macOS b7
      @ObservedObject private var displayGroup : D2SDisplayGroup<Object>
      
      private var entity: Entity { displayGroup.dataSource.entity! }
      
      init(dataSource: ActiveDataSource<Object>, auxiliaryQualifier: Qualifier?) {
        self.displayGroup = D2SDisplayGroup(
          dataSource: dataSource,
          auxiliaryQualifier: auxiliaryQualifier
        )
      }
      
      func handleDoubleTap(on object: OActiveRecord?) {
        guard let object = object else { return } // still a fault
        
        let view = D2SPageView()
          .task(nextTask)
          .ruleObject(object)
          .ruleContext(context)

        let wc = D2SInspectWindow(rootView: view)
        wc.window?.title = title
        wc.window?.setFrameAutosaveName("Inspect:\(title)")
        wc.showWindow(nil)
      }
    
      var body: some View {
        VStack {
          SearchField(search: $displayGroup.queryString)
            .background(Color(NSColor.windowBackgroundColor))
          
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
            .onTapGesture(count: 2) { // this looses the D2SCtx!
              // If we put this too far inside, it doesn't detect clicks
              // on the title text.
              // In b6 it still doesn't click on empty sections of the view.
              self.handleDoubleTap(on: fault.isFault ? nil : fault.object)
            }
          }
        }
      }
    }
  }
#endif // macOS
}
