//
//  MultilineEditor.swift
//  Direct to SwiftUI
//
//  Copyright © 2019 ZeeZide GmbH. All rights reserved.
//

import SwiftUI

#if os(iOS)
import UIKit

struct MultilineEditor: UIViewRepresentable {
  
  @Binding var text : String
    
  func makeUIView(context: Context) -> UITextView {
    let view = UITextView()
    view.isScrollEnabled             = true
    view.isEditable                  = true
    view.isUserInteractionEnabled    = true
    view.allowsEditingTextAttributes = false
    view.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    return view
  }
  
  func updateUIView(_ view: UITextView, context: Context) {
    view.text = text
  }
}
#elseif os(macOS)
#if false // enable once tested
import AppKit

struct MultilineEditor: UIViewRepresentable {
  
  @Binding var text : String
  
  func makeNSView(context: Context) -> NSTextField {
    let view = NSTextField()
    view.allowsEditingTextAttributes = false
    view.importsGraphics             = false
    view.maximumNumberOfLines        = 3
    return view
  }
  
  func updateNSView(_ view: NSTextField, context: Context) {
    view.text = text
  }
}
#endif
#endif
