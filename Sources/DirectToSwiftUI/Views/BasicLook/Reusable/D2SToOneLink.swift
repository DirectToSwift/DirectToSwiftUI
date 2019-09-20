//
//  D2SToOneLink.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI
import class ZeeQLCombine.OActiveRecord

/**
 * This asynchronously fetches the toOne relationship target of the
 * current `\.object` / `\.propertyKey`.
 *
 * While it is being fetched, the `placeholder` is shown,
 * once it is ready the provided `Content`. Which will be
 * filled w/ the proper targetObject in `\.object` and the
 * matching `\.entity`.
 *
 * If the `navigationTask` is set, the content is wrapped in a
 * `NavigationLink` (or tap-window on macOS).
 *
 * See: There is also D2SToOneContainer, which just fetches the destination,
 *      but doesn't wrap in an link.
 */
public struct D2SToOneLink<Content: View, Placeholder: View>: View {
  // TBD: can this reuse D2SToOneContainer?
  //      Probably doable.
  
  @EnvironmentObject private var object : OActiveRecord
  @Environment(\.propertyKey) private var propertyKey
  
  private let content        : Content
  private let placeholder    : Placeholder
  private let navigationTask : String

  public init(navigationTask: String = "inspect",
              placeholder: Placeholder, @ViewBuilder content: () -> Content)
  {
    self.content        = content()
    self.placeholder    = placeholder
    self.navigationTask = navigationTask
  }

  public var body: some View {
    Bound(object: object, propertyKey: propertyKey,
          navigationTask: navigationTask,
          placeholder: placeholder, content: content)
  }
  
  private struct Bound: View {
    
    @ObservedObject private var fetch : D2SToOneFetch
    
    // Strong types crash swiftc https://bugs.swift.org/browse/SR-11409
    private let content        : AnyView
    private let placeholder    : AnyView
    private let navigationTask : String

    init(object: OActiveRecord, propertyKey: String,
         navigationTask: String, placeholder: Placeholder, content: Content)
    {
      self.content        = AnyView(content)
      self.placeholder    = AnyView(placeholder)
      self.navigationTask = navigationTask
      self.fetch = D2SToOneFetch(object: object, propertyKey: propertyKey)
    }
    
    private var targetObject: OActiveRecord? {
      fetch.destination
    }

    #if os(macOS)
      @Environment(\.ruleContext) private var ruleContext
    
      private func handleDoubleClick(on object: OActiveRecord) {
        let view = D2SPageView()
          .task(navigationTask)
          .ruleObject(object)
          .ruleContext(ruleContext)
        
        let title = object.d2s.defaultTitle
        let wc = D2SInspectWindow(rootView: view)
        wc.window?.title = title
        wc.window?.setFrameAutosaveName("Inspect:\(title)")
        wc.showWindow(nil)
      }
    #endif

    public var body: some View {
      Group {
        if fetch.isReady {
          if navigationTask.isEmpty {
            content
              .ruleObject(targetObject!)
              .environment(\.entity, targetObject!.entity)
          }
          else {
            #if os(macOS)
              content
                .ruleObject(targetObject!)
                .environment(\.entity, targetObject!.entity)
                .onTapGesture(count: 2) { // this looses the D2SCtx!
                  self.handleDoubleClick(on: self.targetObject!)
                }
            #else // watchOS requires EnvObj transfer
              D2SNavigationLink(destination: D2SPageView()
                                               .ruleObject(targetObject!))
              {
                content
              }
              .ruleObject(targetObject!)
              .environment(\.entity, targetObject!.entity)
            #endif
          }
        }
        else {
          placeholder
        }
      }
      .onAppear { self.fetch.resume() }
    }
  }
}

public extension D2SToOneLink where Placeholder == D2SNilText {
  
  init(navigationTask: String = "inspect", @ViewBuilder content: () -> Content)
  {
    self.content        = content()
    self.placeholder    = D2SNilText()
    self.navigationTask = navigationTask
  }
}
