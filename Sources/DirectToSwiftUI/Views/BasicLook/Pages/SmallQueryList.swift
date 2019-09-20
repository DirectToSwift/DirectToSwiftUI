//
//  SmallQueryList.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import class ZeeQLCombine.OActiveRecord
import class ZeeQLCombine.ActiveDataSource

public extension BasicLook.Page {
  /**
   * Shows a page containing the contents of an entity.
   *
   * Backed by a D2SDisplayGroup.
   *
   * This simple variant is intended for watchOS.
   */
  struct SmallQueryList: View {
    
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

      // This seems to crash on macOS b7
      @ObservedObject private var displayGroup : D2SDisplayGroup<Object>
      
      init(dataSource: ActiveDataSource<Object>, auxiliaryQualifier: Qualifier?) {
        self.displayGroup = D2SDisplayGroup(
          dataSource: dataSource,
          auxiliaryQualifier: auxiliaryQualifier
        )
      }

      var body: some View {
        VStack {
          List(displayGroup.results) { fault in
            D2SFaultObjectLink(fault: fault)
          }
        }
      }
    }
  }
}
