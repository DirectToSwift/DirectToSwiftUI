//
//  UIKitSelect.swift
//  DirectToSwift
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import class ZeeQLCombine.OActiveRecord
import class ZeeQLCombine.ActiveDataSource

public extension BasicLook.Page.UIKit {

#if !os(iOS)
  static func Select() -> some View {
    Text("\(#function) is not available on this platform")
  }
#else

  /**
   * Edit a relationship.
   *
   * Backed by a D2SDisplayGroup.
   *
   * This version is intended for iOS.
   */
  struct Select: View {
    // Note: This is _almost_ a dupe of the QueryList page. But not quite.

    @Environment(\.database)            private var db
    @Environment(\.entity)              private var entity
    @Environment(\.auxiliaryQualifier)  private var auxiliaryQualifier
    @Environment(\.displayPropertyKeys) private var displayPropertyKeys
    @Environment(\.relationship)        private var relationship
    @EnvironmentObject                  private var sourceObject : OActiveRecord

    public init() {}

    private func makeDisplayGroup() -> D2SDisplayGroup<OActiveRecord> {
      return D2SDisplayGroup(
        dataSource          : ActiveDataSource(database: db, entity: entity),
        auxiliaryQualifier  : auxiliaryQualifier,
        displayPropertyKeys : displayPropertyKeys
      )
    }
    
    public var body: some View {
      // Right now we only do single-select aka toOne
      Group {
        if relationship.isToMany {
          Text("Not supporting\nToMany selection\njust yet.")
        }
        else {
          SingleSelect(displayGroup: makeDisplayGroup(),
                       sourceObject: sourceObject,
                       initialID: JoinTargetID(source: sourceObject,
                                               relationship: relationship))
            .environment(\.auxiliaryQualifier, nil) // reset!
        }
      }
    }

    struct SingleSelect<Object: OActiveRecord>: View {

      typealias Fault = D2SFault<Object, D2SDisplayGroup<Object>>

      @ObservedObject var displayGroup : D2SDisplayGroup<Object>
      @ObservedObject var sourceObject : OActiveRecord
      
      @Environment(\.relationship)     private var relationship

      @Environment(\.entity)           private var entity
      @Environment(\.debugComponent)   private var debugComponent
      @Environment(\.rowComponent)     private var rowComponent
      @Environment(\.presentationMode) private var presentationMode

      @State var selectedID     : FaultJoinIDWrap.ID?
      @State var isShowingError = false
      
      init(displayGroup : D2SDisplayGroup<Object>,
           sourceObject : OActiveRecord,
           initialID    : JoinTargetID?)
      {
        self.displayGroup = displayGroup
        self.sourceObject = sourceObject
        self._selectedID  = State(initialValue: initialID.flatMap({.object($0)}))
      }
      
      private func id(for object: Object) -> FaultJoinIDWrap.ID {
        // The selection aka relationship target is not necessarily a
        // primary key! One can join other attributes as well!
        .object(JoinTargetID(destination: object, relationship: relationship))
      }
      
      private var selectedObject: Object? {
        guard let id = selectedID else { return nil }
        return displayGroup.results.firstAvailableObject { object in
          id == self.id(for: object)
        }
      }
      
      private func goBack() {
        presentationMode.wrappedValue.dismiss()
      }

      private func saveSelection() {
        assert(relationship !== D2SKeys.relationship.defaultValue,
               "called w/ default relationship")
        
        if let targetObject = selectedObject {
          sourceObject.wire(destination: targetObject, to: relationship)
          goBack()
        }
        else if selectedID != nil {
          globalD2SLogger.error("object not yet fetched:", selectedID)
          isShowingError = true
        }
        else { // nil case
          sourceObject.wire(destination: nil, to: relationship)
          goBack()
        }
      }
      
      private var isValid: Bool {
        if relationship.isMandatory && selectedID == nil { return false }
        return true
      }
      
      private func errorAlert() -> Alert {
        Alert(title: Text("Missing Object"),
              message: Text("Selection not available"),
              dismissButton: .default(Text("🤷‍♀️")))
      }
      
      struct FaultJoinIDWrap: Identifiable {
        enum ID: Hashable {
          case fault(GlobalID)
          case object(JoinTargetID)
        }
        let fault : Fault
        let id    : ID
        init(fault: Fault, relationship: Relationship) {
          self.fault = fault
          switch fault {
            case .fault (let gid, _):    self.id = .fault(gid)
            case .object(_, let object):
              self.id = .object(JoinTargetID(destination: object,
                                             relationship: relationship))
          }
        }
      }
      private var mappedResults: [ FaultJoinIDWrap ] {
        // FIXME: this is kinda expensive because it isn't sparse, i.e. it maps
        //        over as many faults as the destination has rows :-/
        return displayGroup.results.map {
          FaultJoinIDWrap(fault: $0, relationship: relationship)
        }
      }

      var body: some View {
        VStack(spacing: 0) {
          SearchField(search: $displayGroup.queryString)
          
          List(mappedResults, selection: $selectedID) { wrap in
            D2SFaultContainer(fault: wrap.fault) { object in
              self.rowComponent
                .tag(self.id(for: object))
            }
          }
          .environment(\.editMode, .constant(EditMode.active)) // required

          debugComponent
        }
        .alert(isPresented: $isShowingError, content: errorAlert)
        .navigationBarItems(trailing:
          HStack {
            Button(action: self.saveSelection) {
              Text("Apply")
            }
            .disabled(!isValid)
          }
        )
      }
    }
  }
#endif // iOS
}
