//
//  D2STitleText.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * A `Text` which shows the title of the object which is active in the
 * environment.
 */
public struct D2STitleText: View {
  
  @EnvironmentObject private var object : OActiveRecord // to get refreshes
  @Environment(\.title) private var title
  
  public init() {}

  public var body: some View { Text(verbatim: title) }
}
