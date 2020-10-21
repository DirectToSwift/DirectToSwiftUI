//
//  D2SRuleEnvironment.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import class  SwiftUIRules.RuleModel
import struct SwiftUIRules.RuleContext
import SwiftUI
import Combine
import ZeeQL

/**
 * Used to fetch the model from the database, if necessary.
 */
public final class D2SRuleEnvironment: ObservableObject {
  
  public var isReady  : Bool { databaseModel != nil }
  public var hasError : Bool { error         != nil }

  @Published public var databaseModel : ZeeQL.Model?
  @Published public var error         : Swift.Error?
  @Published public var ruleContext   : RuleContext
  
  public let adaptor     : Adaptor
  public let ruleModel   : RuleModel

  public init(adaptor: Adaptor, ruleModel: RuleModel) {
    self.adaptor   = adaptor
    self.ruleModel = ruleModel
    
    ruleContext = RuleContext(ruleModel: ruleModel)
    ruleContext[D2SKeys.database] = Database(adaptor: adaptor)
    
    if let model = adaptor.model {
      setupWithModel(model)
    }
  }
  
  private func setupWithModel(_ model: Model) {
    self.databaseModel = model
    ruleContext[D2SKeys.model] = model
  }
  
  private var modelFetch : AnyCancellable?
  
  public func resume() {
    guard databaseModel == nil else { return }
    
    // TODO: setup timer to refetch and compare model tag
    modelFetch = adaptor.fetchModel(on: D2SFetchQueue)
      .map { ( model, tag ) in
        FancyModelMaker(model: model).fancyfyModel()
      }
      .receive(on: RunLoop.main)
      .catch { ( error : Swift.Error ) -> Just<Model> in
        self.error = error
        globalD2SLogger.error("failed to fetch model:", error)
        self.modelFetch = nil
        return Just(Model(entities: [
          ModelEntity(name: "Could not load model.")
        ]))
      }
      .sink { model in
        if self.error == nil {
          self.adaptor.model = model
        }
        self.setupWithModel(model)
        self.modelFetch = nil
      }
  }
}
