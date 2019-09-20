//
//  Platform.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

public enum Platform: Hashable {
  
  case desktop, watch, phone, pad, tv
  
  public static var `default`: Platform {
    #if os(macOS)
      return .desktop
    #elseif os(iOS)
      return .phone // TODO: .pad?!
    #elseif os(watchOS)
      return .watch
    #elseif os(tvOS)
      return .tv
    #else
      return .phone
    #endif
  }
}
