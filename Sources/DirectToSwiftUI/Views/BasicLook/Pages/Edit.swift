//
//  Edit.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import class ZeeQLCombine.OActiveRecord

public extension BasicLook.Page {
  
  /**
   * A view for editing the properties of an object.
   *
   * Iterates over the `displayPropertyKeys` and shows the respective property
   * edit views.
   */
  struct Edit: View {

    struct Content: View {
      
      @Environment(\.debugComponent) private var debugComponent
      @EnvironmentObject private var object : ZeeQLCombine.OActiveRecord
      
      #if os(iOS) // do not use Form on iOS
        public var body: some View {
          VStack {
            D2SDisplayPropertiesList()
            debugComponent
          }
          .task(.edit)
        }
      #else
        public var body: some View {
          VStack {
            Form {
              D2SDisplayProperties() // form scrolls etc
            }
            debugComponent
          }
          .task(.edit)
        }
      #endif
    }
      
    #if os(iOS)
      struct ContentWithNavigationBar: View {
        
        @EnvironmentObject private var object : OActiveRecord

        @Environment(\.presentationMode) private var presentationMode
        
        @State private var lastError      : Swift.Error?
        @State private var isShowingError = false
        
        private var errorMessage: String {
          guard let error = lastError else { return "No Error" }
          return String(describing: error)
        }

        private var hasChanges: Bool {
          object.hasChanges // TODO: probably need to subscribe to object for this!
        }
        
        func goBack() {
          // that feels dirty
          // programmatically POP the edit page
          // I think a NavLink is necessary here (plus a binding to pass along)
          presentationMode.wrappedValue.dismiss()
        }
        
        private func save() {
          guard hasChanges else { return goBack() }
          
          do {
            try object.save()
            goBack()
          }
          catch {
            globalD2SLogger.error("failed to save object:", error)
            lastError = error
            isShowingError = true
          }
        }
        private func discard() {
          object.revert()
        }
        
        private func errorAlert() -> Alert {
          // TODO: Improve on the error message
          if object.isNew {
            return Alert(title: Text("Create Failed"),
                         message: Text(errorMessage),
                         dismissButton: .default(Text("Retry"), action: self.save)
            )
          }
          else {
            return Alert(title: Text("Save Failed"),
                         message: Text(errorMessage),
                         primaryButton: .destructive(Text("Discard"),
                                                     action: self.discard),
                         secondaryButton: .default(Text("Retry"),
                                                   action: self.save)
            )
          }
        }

        var body: some View {
          Content()
            .navigationBarItems(trailing: Group {
              HStack {
                Button(action: self.discard) {
                  Image(systemName: "trash.circle")
                }
                Button(action: self.save) { // text looks better
                  Text(object.isNew ? "Create" : "Save")
                }
              }
              .disabled(!hasChanges)
            })
            .alert(isPresented: $isShowingError, content: errorAlert)
        }
      }
      
      public var body: some View {
        ContentWithNavigationBar()
      }
    #else
      public var body: some View {
        Content()
      }
    #endif
  }
}
