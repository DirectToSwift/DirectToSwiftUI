//
//  D2SPropertyValue.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

/**
 * This shows the value of the property using the View applicable for the
 * current environment.
 *
 * It queries the `component` environment key which resolves to the proper
 * View for the property + entity + task.
 *
 * It is the same (but less typing) as:
 *
 *     @Environment(\.component) var component
 *
 */
public struct D2SComponentView: View {
  
  @Environment(\.component) public var body
  
}
