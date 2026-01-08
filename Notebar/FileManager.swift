//
//  FileManager.swift
//  Notebar
//
//  Created for file-based note storage
//

import Foundation
import AppKit

class NoteFileManager: ObservableObject {
    @Published var fileURL: URL? {
        didSet {
            if let url = fileURL {
                UserDefaults.standard.set(url.path, forKey: "notesFilePath")
            } else {
                UserDefaults.standard.removeObject(forKey: "notesFilePath")
            }
        }
    }
    
    init() {
        // Load saved file path
        if let savedPath = UserDefaults.standard.string(forKey: "notesFilePath") {
            self.fileURL = URL(fileURLWithPath: savedPath)
        }
    }
    
    func selectFile() -> Bool {
        // Use NSOpenPanel to select existing files (no replacement warning)
        // This allows selecting existing files without the "file will be replaced" warning
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.text, .plainText]
        panel.title = "Select Notes File"
        panel.prompt = "Select"
        panel.canCreateDirectories = false
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                self.fileURL = url
                return true
            }
        }
        return false
    }
    
    func createNewFile() -> Bool {
        // Use NSSavePanel for creating new files
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.text, .plainText]
        panel.nameFieldStringValue = "notes.md"
        panel.canCreateDirectories = true
        panel.title = "Create Notes File"
        panel.prompt = "Create"
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                // If file doesn't exist, create it
                if !FileManager.default.fileExists(atPath: url.path) {
                    FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
                }
                self.fileURL = url
                return true
            }
        }
        return false
    }
    
    func loadText() -> String {
        guard let url = fileURL else { return "" }
        
        do {
            let text = try String(contentsOf: url, encoding: .utf8)
            return text
        } catch {
            print("Error loading file: \(error)")
            return ""
        }
    }
    
    func saveText(_ text: String) {
        guard let url = fileURL else { return }
        
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
    func getFileName() -> String {
        if let url = fileURL {
            return url.lastPathComponent
        }
        return "No file selected"
    }
}
