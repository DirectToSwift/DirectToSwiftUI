//
//  D2SToOneContainer.swift
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
 */
public struct D2SToOneContainer<Content: View, Placeholder: View>: View {
  
  @EnvironmentObject private var object : OActiveRecord
  @Environment(\.propertyKey) private var propertyKey
  
  private let content        : Content
  private let placeholder    : Placeholder

  public init(placeholder: Placeholder, @ViewBuilder content: () -> Content) {
    self.content     = content()
    self.placeholder = placeholder
  }

  public var body: some View {
    Bound(object: object, propertyKey: propertyKey,
          placeholder: placeholder, content: content)
  }
  
  private struct Bound: View {
    
    @ObservedObject private var fetch : D2SToOneFetch
    
    // Strong types crash swiftc https://bugs.swift.org/browse/SR-11409
    private let content        : AnyView
    private let placeholder    : AnyView

    init(object: OActiveRecord, propertyKey: String,
         placeholder: Placeholder, content: Content)
    {
      self.content     = AnyView(content)
      self.placeholder = AnyView(placeholder)
      self.fetch = D2SToOneFetch(object: object, propertyKey: propertyKey)
    }
    
    private var targetObject: OActiveRecord? {
      fetch.destination
    }

    #if os(macOS)
      @Environment(\.ruleContext) private var ruleContext
    
      private func handleDoubleClick(on object: OActiveRecord) {
        let view = D2SPageView()
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
          content
            .ruleObject(targetObject!)
            .environment(\.entity, targetObject!.entity)
        }
        else {
          placeholder
        }
      }
      .onAppear { self.fetch.resume() }
    }
  }
}

public extension D2SToOneContainer where Placeholder == D2SNilText {
  
  init(@ViewBuilder content: () -> Content) {
    self.content     = content()
    self.placeholder = D2SNilText()
  }
}
