//
//  D2SDebugObjectEditInfo.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import Combine

fileprivate let changeCount = 0

/**
 * Show debug info about the editing state of an object.
 */
public struct D2SDebugObjectEditInfo: View {
  
  @EnvironmentObject private var object : OActiveRecord

  public var body: some View {
    D2SDebugBox {
      if object.d2s.isDefault {
        Text("No object set")
      }
      else {
        Text(verbatim: object.entity.displayNameWithExternalName)
          .font(.title)
        Text(verbatim: "\(object)")
          .lineLimit(3)
        Text(verbatim: "\(changeCount)")

        if object.isNew {
          Text("Object is new")
          Changes(object: object)
        }
        else if object.hasChanges {
          Text("Object has changes")
          Changes(object: object)
        }
      }
    }
    .lineLimit(1)
  }
  
  struct Changes: View {
    
    @ObservedObject var object : OActiveRecord
    
    private var changes : [ ( key: String, value: Any? ) ] {
      if object.isNew {
        return object.values.sorted(by: { $0.key < $1.key })
      }
      else {
        return object.changesFromSnapshot(object.snapshot ?? [:])
                     .sorted(by: { $0.key < $1.key })
      }
    }

    var body: some View {
      VStack {
        ForEach(changes, id: \.key) { pair in
          HStack {
            Text(pair.key)
            Spacer()
            if pair.value == nil {
              Text("nil")
            }
            else {
              Text(String(describing: pair.value!))
            }
          }
        }
      }
    }
  }
}
