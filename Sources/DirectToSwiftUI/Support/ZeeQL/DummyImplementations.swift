//
//  DummyImplementations.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

// Those are here to workaround the issue that we don't want any
// optionals in Views. Which may or may not be a good decision.

import class    ZeeQL.SQLExpressionFactory
import class    ZeeQL.Database
import protocol ZeeQL.Adaptor
import protocol ZeeQL.AdaptorChannel

internal final class D2SDummyDatabase: Database {
  init() { super.init(adaptor: DummyAdaptor()) }
  
  private final class DummyAdaptor: Adaptor {
    struct DummyModelTag: ModelTag {
      func isEqual(to object: Any?) -> Bool { return false }
    }
    func openChannel() throws -> AdaptorChannel {
      fatalError("can't open channel on dummy adaptor")
    }
    let expressionFactory = SQLExpressionFactory()
    var model             : Model?
    
    func fetchModel()    throws -> Model    { Model(entities: []) }
    func fetchModelTag() throws -> ModelTag { DummyModelTag() }
  }
}

internal final class D2SDefaultModel: Model {
  init() {
    super.init(entities: [])
  }
}

internal final class D2SDefaultEntity: Entity {
  static let shared = D2SDefaultEntity()
  var name          : String           { ""    }
  var isPattern     : Bool             { false }
  var attributes    : [ Attribute    ] { []    }
  var relationships : [ Relationship ] { []    }
}

internal final class D2SDefaultAttribute: Attribute {
  var name: String { "" }
}

internal final class D2SDefaultRelationship: Relationship {
  var name              : String   { ""    }
  var entity            : Entity   { D2SDefaultEntity.shared }
  var destinationEntity : Entity?  { nil   }
  var isToMany          : Bool     { false }
  var joins             : [ Join ] { []    }
  var isPattern         : Bool     { false }
  var relationshipPath  : String?  { ""    }
}
