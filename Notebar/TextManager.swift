//
//  TextManager.swift
//  Notebar
//
//  Created by Jay Stakelon on 2/6/21.
//

import SwiftUI
import Combine

class TextManager: ObservableObject {
    @Published var text: String = "" {
        didSet {
            // Auto-save to file when text changes
            if let fileManager = fileManager {
                fileManager.saveText(text)
            }
        }
    }
    
    private var fileManager: NoteFileManager?
    private var saveTimer: Timer?
    
    init(fileManager: NoteFileManager? = nil) {
        self.fileManager = fileManager
        
        // Load initial text from file if file manager is available
        if let fileManager = fileManager {
            self.text = fileManager.loadText()
            
            // Observe file manager changes to reload when file changes
            fileManager.$fileURL.sink { [weak self] newURL in
                if let self = self, newURL != nil {
                    self.text = fileManager.loadText()
                }
            }.store(in: &cancellables)
        } else {
            // Fallback to UserDefaults if no file manager
            if let data = UserDefaults.standard.object(forKey: "text") as? String {
                self.text = data
            }
        }
    }
    
    func setFileManager(_ fileManager: NoteFileManager) {
        self.fileManager = fileManager
        // Load text from new file
        self.text = fileManager.loadText()
        
        // Observe file URL changes
        fileManager.$fileURL.sink { [weak self] newURL in
            guard let self = self, let fileManager = self.fileManager else { return }
            if newURL != nil {
                self.text = fileManager.loadText()
            }
        }.store(in: &cancellables)
        
        // Observe file change notifications
        NotificationCenter.default.publisher(for: NSNotification.Name("NoteFileChanged"))
            .sink { [weak self] _ in
                guard let self = self, let fileManager = self.fileManager else { return }
                self.text = fileManager.loadText()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}
