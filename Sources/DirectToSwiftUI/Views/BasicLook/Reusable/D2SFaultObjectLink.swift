//
//  D2SFaultObjectLink.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import class ZeeQL.ActiveRecord

/**
 * This takes a `D2SFault`. If it still is a fault, it shows some wildcard
 * view.
 * If it is an object, it embeds the object in a `NavigationLink` which shows
 * the `nextTask` with the object bound.
 */
public struct D2SFaultObjectLink<Object: OActiveRecord, Destination: View,
                                 Content: View>: View
{
  public typealias Fault = D2SFault<Object, D2SDisplayGroup<Object>>
  
  @Environment(\.task)     var task
  @Environment(\.nextTask) var nextTask
  
  private let action      : D2SObjectAction
  private let fault       : Fault
  private let destination : Destination
  private let content     : Content
    // TBD: should the content get selected using the `rowComponent`?
    //      Probably.
  
  private let isActive    : Binding<Bool>?

  init(fault: Fault, destination: Destination,
       action: D2SObjectAction = .nextTask,
       isActive: Binding<Bool>? = nil,
       @ViewBuilder content: () -> Content)
  {
    self.isActive    = isActive
    self.action      = action
    self.fault       = fault
    self.destination = destination
    self.content     = content()
  }
  
  private var taskToInvoke: String {
    return action.action(task: task, nextTask: nextTask)
  }
  
  public var body: some View {
    // This has sizing issues on the first load. The cells have the wrong
    // height.
    // Maybe we need to make the Fault an observed object?
    Group {
      if fault.accessingFault() { D2SRowFault() }
      else {
        D2SNavigationLink(destination: destination.task(taskToInvoke)
                                                  .ruleObject(fault.object),
                          isActive: isActive)
        {
          content.ruleObject(fault.object)
        }
      }
    }
  }
}

public extension D2SFaultObjectLink where Content == D2STitledSummaryView {
  init(fault: Fault, destination: Destination,
       action: D2SObjectAction = .nextTask, isActive: Binding<Bool>? = nil)
  {
    self.isActive    = isActive
    self.action      = action
    self.fault       = fault
    self.destination = destination
    self.content     = D2STitledSummaryView()
  }
}

public extension D2SFaultObjectLink where Destination == D2SPageView,
                                          Content == D2STitledSummaryView
{
  init(fault: Fault,
       action: D2SObjectAction = .nextTask, isActive: Binding<Bool>? = nil)
  {
    self.isActive    = isActive
    self.fault       = fault
    self.destination = D2SPageView()
    self.content     = D2STitledSummaryView()
    self.action      = action
  }
}
public extension D2SFaultObjectLink where Destination == D2SPageView {
  init(fault: Fault,
       action: D2SObjectAction = .nextTask, isActive: Binding<Bool>? = nil,
       @ViewBuilder content: () -> Content)
  {
    self.isActive    = isActive
    self.fault       = fault
    self.destination = D2SPageView()
    self.content     = content()
    self.action      = action
  }
}
