//
//  D2SDebugDatabaseInfo.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

public struct D2SDebugDatabaseInfo: View {
  
  @Environment(\.database) var database

  public var body: some View {
    D2SDebugBox {
      if database.d2s.isDefault {
        Text("Dummy Database!")
      }
      else {
        Text(verbatim: database.d2s.defaultTitle)
          .font(.title)
        Text(verbatim: "\(database)")
        if database.adaptor.url != nil {
          Text(verbatim: "\(database.adaptor.url!)")
            .lineLimit(1)
        }
        if database.model == nil {
          Text("No model")
        }
        else {
          Text("Model: #\(database.model!.entities.count) entities")
        }
        Text(verbatim: "\(database.adaptor)")
          .lineLimit(3)
      }
    }
  }
}
