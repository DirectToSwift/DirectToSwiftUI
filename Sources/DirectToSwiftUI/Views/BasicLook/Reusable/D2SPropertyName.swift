//
//  D2SPropertyName.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * A text representing the display name of the active property.
 */
public struct D2SPropertyName: View {
  
  @Environment(\.displayNameForProperty) private var label
  
  public var body: some View { Text(label) }
}

/**
 * A text representing the display name of the active property.
 *
 * This one is a variant which shows the label as a subheadline above the
 * field.
 */
public struct D2SPropertyNameHeadline: View {
  
  private let isValid : Bool
  
  public init(isValid: Bool = true) {
    self.isValid = isValid
  }
  
  @Environment(\.displayNameForProperty) private var label
  
  public var body: some View {
    HStack {
      (Text(label) + Text(verbatim: ":"))
        .foregroundColor(isValid ? .secondary : .red)
        .font(.subheadline)
      Spacer()
    }
  }
}

/**
 * A text representing the display name of the active property.
 *
 * This one is a variant which colors the text based on validity.
 */
public struct D2SEditPropertyName: View {
  
  private let isValid : Bool
  
  public init(isValid: Bool = true) {
    self.isValid = isValid
  }
  
  @Environment(\.displayNameForProperty) private var label
  
  public var body: some View {
    Text(label)
      .foregroundColor(isValid ? nil : .red)
  }
}
