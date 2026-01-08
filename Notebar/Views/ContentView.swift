//
//  ContentView.swift
//  Notebar
//
//  Created by Jay Stakelon on 1/1/21.
//

import SwiftUI
import MbSwiftUIFirstResponder
import AppKit

extension Color {
    var nsColor: NSColor {
        return NSColor(self)
    }
}

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear //<<here clear
            drawsBackground = true
        }
    }
}

enum FirstResponders: Int {
    case textEditor
}

struct ContentView: View {
    private var placeholder: String = "hello there"
    @State var firstResponder: FirstResponders? = FirstResponders.textEditor
    @State var isPreviewMode: Bool = false
    @ObservedObject var themeManager = ThemeManager()
    @ObservedObject var fileManager = NoteFileManager()
    @StateObject private var textManager = TextManager()
    
    private var markdownAttributedString: NSAttributedString {
        let textColor = themeManager.textColor.nsColor
        let bgColor = themeManager.bgColor.nsColor
        return MarkdownRenderer.render(
            markdownText: textManager.text,
            textColor: textColor,
            backgroundColor: bgColor
        )
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HeaderView(themeManager: themeManager, isPreviewMode: $isPreviewMode, fileManager: fileManager)
                ZStack(alignment: .topLeading) {
                    if isPreviewMode {
                        MarkdownPreviewView(
                            attributedString: markdownAttributedString,
                            backgroundColor: themeManager.bgColor.nsColor
                        )
                    } else {
                        TextEditor(text: $textManager.text)
                            .firstResponder(id: FirstResponders.textEditor, firstResponder: $firstResponder)
                            .font(Font.system(.body, design: .monospaced))
                            .padding(.leading, -5)
                            .foregroundColor(themeManager.textColor)
                        if (textManager.text == "") {
                            Text(placeholder)
                                .font(Font.system(.body, design: .monospaced))
                                .foregroundColor(themeManager.textColor)
                                .opacity(0.4)
                        }
                    }
                }.accentColor(.yellow)
                .padding(12)
                .background(themeManager.bgColor)
            }
            ZStack {
//                if themeManager.isThemeEditor {
                    Color(.shadowColor)
                        .opacity(themeManager.isThemeEditor ? 0.5 : 0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            themeManager.hideThemeEditor()
                            firstResponder = FirstResponders.textEditor
                        }
                        .animation(.easeOut(duration: 0.25))
                    ThemeEditorView(themeManager: themeManager)
                        .frame(width: 240, height: 240)
                        .offset(y: themeManager.isThemeEditor ? 0 : 400)
                        .animation(.easeOut(duration: 0.25))
//                }
                
            }
        }
        .background(Color(.windowBackgroundColor))
        .onAppear {
            // Set up file manager connection
            textManager.setFileManager(fileManager)
            // If no file is selected, prompt for one
            if fileManager.fileURL == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    _ = fileManager.selectFile()
                    textManager.setFileManager(fileManager)
                }
            }
        }
        .onChange(of: fileManager.fileURL) { _ in
            // Reload text when file changes
            textManager.setFileManager(fileManager)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

