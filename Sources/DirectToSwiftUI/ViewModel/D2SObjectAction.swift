//
//  D2SObjectAction.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

public enum D2STask : Hashable {
  // Note: We don't want to use this enum instead of the string in the
  //       ruleContext, because it wouldn't fly well w/ KVC based qualifiers.
  
  case query
  case list
  case inspect
  case edit
  case select
  case login
  case error
  case custom(String)
  
  public init<S: StringProtocol>(_ string: S) {
    switch string {
      case "inspect" : self = .inspect
      case "edit"    : self = .edit
      case "query"   : self = .query
      case "list"    : self = .list
      case "select"  : self = .select
      case "login"   : self = .login
      case "error"   : self = .error
      default        : self = .custom(String(string))
    }
  }
  
  public var stringValue: String {
    switch self {
      case .inspect       : return "inspect"
      case .edit          : return "edit"
      case .query         : return "query"
      case .list          : return "list"
      case .select        : return "select"
      case .login         : return "login"
      case .error         : return "error"
      case .custom(let s) : return s
    }
  }
}
extension D2STask : ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self.init(value)
  }
}

// Like a D2STask, but has the additional `task` and `nextTask` cases for
// context sensitive actions.
public enum D2SObjectAction : Hashable {
  // FIXME: better name, this is not really an `action`?
  
  case task
  case nextTask
  
  case query
  case list
  case inspect
  case edit
  case select
  case login
  case error

  case custom(String)
  
  func action(task: String, nextTask: String) -> String {
    switch self {
      case .task          : return task
      case .nextTask      : return nextTask
      
      case .inspect       : return "inspect"
      case .edit          : return "edit"
      case .query         : return "query"
      case .list          : return "list"
      case .select        : return "select"
      case .login         : return "login"
      case .error         : return "error"

      case .custom(let s) : return s
    }
  }
}
