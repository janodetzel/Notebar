//
//  MarkdownPreviewView.swift
//  Notebar
//
//  Created for markdown preview functionality
//

import SwiftUI
import AppKit

struct MarkdownPreviewView: NSViewRepresentable {
    let attributedString: NSAttributedString
    let backgroundColor: NSColor
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = backgroundColor
        textView.textStorage?.setAttributedString(attributedString)
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.autoresizingMask = [.width, .height]
        
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.backgroundColor = backgroundColor
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        if let textView = nsView.documentView as? NSTextView {
            textView.textStorage?.setAttributedString(attributedString)
            textView.backgroundColor = backgroundColor
            nsView.backgroundColor = backgroundColor
        }
    }
}
