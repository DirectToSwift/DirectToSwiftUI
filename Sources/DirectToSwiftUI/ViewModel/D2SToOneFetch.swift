//
//  D2SToOneFetch.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import Combine
import SwiftUI
import class ZeeQLCombine.OActiveRecord

/**
 * This is used to fetch the toOne relship of an object.
 */
public final class D2SToOneFetch: ObservableObject {
  
  @Published var destination : OActiveRecord?
  
  let object      : OActiveRecord
  let propertyKey : String
  
  var isReady : Bool { destination != nil }
  
  private var fetchToken : AnyCancellable?
  
  public init(object: OActiveRecord, propertyKey: String) {
    self.object      = object
    self.propertyKey = propertyKey
    
    func lookup(_ kp: String, in object: OActiveRecord) -> OActiveRecord? {
      KeyValueCoding.valueForKeyPath(kp, inObject: object)
        as? OActiveRecord
    }
    
    self.destination = lookup(propertyKey, in: object)
  }
  
  func resume() {
    guard destination == nil, fetchToken == nil else { return }
    
    // Note: This _does_ try to fetch `nil` values, which is not strictly
    //       wrong.
    
    fetchToken = object.fetchToOneRelationship(propertyKey)
      .receive(on: RunLoop.main)
      .catch { ( error : Swift.Error ) -> Just<OActiveRecord?> in
        return Just(nil)
      }
      .sink { newValue in
        // Update the AR. This is a little meh, but avoids continuous fetches.
        try? KeyValueCoding.takeValue(newValue, forKeyPath: self.propertyKey,
                                      inObject: self.object)
        self.destination = newValue
        self.fetchToken  = nil
      }
  }
}
