//
//  MainView.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import class  SwiftUIRules.RuleModel
import struct SwiftUIRules.RuleContext
import SwiftUI

public struct D2SMainView: View {
  
  // TODO: needs login state and async fetches
  
  @ObservedObject private var viewModel : D2SRuleEnvironment
  
  public init(adaptor: Adaptor, ruleModel: RuleModel) {
    viewModel = D2SRuleEnvironment(
      adaptor   : adaptor,
      ruleModel : ruleModel.fallback(D2SDefaultRules)
    )
    
    viewModel.resume()
  }
  
  public var body: some View {
    Group {
      if viewModel.isReady {
        PageWrapperSelect()
          .ruleContext(viewModel.ruleContext)
          .environmentObject(viewModel)
      }
      else if viewModel.hasError {
        ErrorView(error: viewModel.error!)
          .padding()
      }
      else {
        ConnectProgressView()
          .padding()
      }
    }
  }

  struct PageWrapperSelect: View {
    
    @Environment(\.pageWrapper) var wrapper
    @Environment(\.firstTask)   var firstTask
    
    var body: some View {
      wrapper
        .task(firstTask)
    }
  }

  struct ErrorView: View {
    // TODO: Make nice. Make generic. Detect specific types.
    // Maybe add an error env key. I think D2W even has an error task.
    
    let error : Swift.Error
    
    var body: some View {
      VStack {
        Spacer()
        Text(verbatim: "\(error)")
        Spacer()
      }
    }
  }
  
  struct ConnectProgressView: View {
    
    @State var isSpinning = false
    
    var body: some View {
      VStack {
        Text("Connecting database ...")
        Spacer()
        Spinner(isAnimating: isSpinning, speed: 1.8, size: 64)
        Spacer()
      }
      .onAppear { self.isSpinning = true } // seems necessary
    }
  }
}
