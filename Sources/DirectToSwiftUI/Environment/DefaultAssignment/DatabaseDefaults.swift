//
//  D2SDatabase.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import class ZeeQL.Database

public extension Database {
  
  var d2s : D2S { return D2S(database: self) }
  
  struct D2S {
    let database: Database

    public var isDefault : Bool { database === D2SKeys.database.defaultValue }
    
    public var hasDefaultTitle: Bool {
      if let url = database.adaptor.url, !url.path.isEmpty {
        return !url.deletingPathExtension().lastPathComponent.isEmpty
      }
      return false
    }

    public var defaultTitle : String {
      if let url = database.adaptor.url, !url.path.isEmpty {
        let n = url.deletingPathExtension().lastPathComponent
        if !n.isEmpty { return n }
      }
      
      return "Database" // /shrug
    }
  }
}
