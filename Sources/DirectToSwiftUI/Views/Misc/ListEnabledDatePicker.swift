//
//  D2SDatePicker.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * Reimplementation of Form DatePicker. Required because Form-DatePickers
 * do not work properly when embedded in a ForEach/List (FB7212377).
 */
public struct ListEnabledDatePicker: View {
  
  private static let formatter : DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .short
    df.timeStyle = .short
    df.doesRelativeDateFormatting = true // today, tomorrow
    return df
  }()
  
  private let selection : Binding<Date>
  private let title : String
  
  @State var isEditing : Bool = false
  
  var textDate : String {
    ListEnabledDatePicker.formatter.string(from: selection.wrappedValue)
  }
  
  init(_ title: String, selection: Binding<Date>) {
    self.title     = title
    self.selection = selection
  }
  
  private var editColor : Color {
    #if os(iOS)
      return Color(UIColor.systemBlue) // TBD
    #elseif os(macOS)
      return Color(NSColor.systemBlue) // FIXME, use proper predefined
    #else
      return Color.blue
    #endif
  }

  #if os(watchOS) // no DatePicker on watchOS. TODO: implement one
    public var body: some View {
      HStack {
        Text(title)
        Spacer() // FIXME: spacer ignores taps
        Text(verbatim: textDate)
          .foregroundColor(isEditing ? editColor : .secondary)
      }
    }
  #else
    public var body: some View {
      VStack {
        if isEditing { // Hack to fix the padding shrink when expanded
          Spacer()
            .frame(height: 6)
        }
        
        HStack {
          Text(title)
          Spacer()
          Text(verbatim: textDate)
            .foregroundColor(isEditing ? editColor : .secondary)
        }
        .contentShape(Rectangle()) // to make the whole thing tap'able
          .onTapGesture { self.isEditing.toggle() }

        if isEditing {
          Divider()
          DatePicker(selection: selection) { EmptyView() }
        }
      }
    }
  #endif
}
