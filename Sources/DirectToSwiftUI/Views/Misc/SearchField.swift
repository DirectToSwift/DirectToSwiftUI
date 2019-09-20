//
//  SearchField.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

struct SearchField: View {
  
  @Binding var search: String
  var onSearch : () -> Void = { }
  
  #if os(iOS)
    var body: some View {
      HStack {
        Image(systemName: "magnifyingglass")
        
        TextField("Search", text: $search, onCommit: onSearch)
          .textFieldStyle(RoundedBorderTextFieldStyle())
      }
      .padding()
    }
  #elseif os(macOS)
    var body: some View {
      TextField("Search", text: $search, onCommit: onSearch)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
    }
  #else // watchOS
    var body: some View {
      TextField("Search", text: $search, onCommit: onSearch)
        .padding()
    }
  #endif
}
