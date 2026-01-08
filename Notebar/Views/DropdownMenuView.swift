//
//  DropdownMenuView.swift
//  Notebar
//
//  Created by Jay Stakelon on 1/30/21.
//

import SwiftUI

struct DropdownMenuView: NSViewRepresentable {
    
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var fileManager: NoteFileManager
        
    func makeNSView(context: Context) -> NSPopUpButton {
        
        let dropdown = NSPopUpButton(frame: CGRect(x: 0, y: 0, width: 48, height: 24), pullsDown: true)
        dropdown.menu!.autoenablesItems = false
        return dropdown
        
    }
    
    func updateNSView(_ nsView: NSPopUpButton, context: Context) {
        
        nsView.removeAllItems()
        
        let iconItem = NSMenuItem()
//        let iconImage = NSImage(named: "GearIcon")
//        iconImage?.size = NSSize(width: 12, height: 12)
//        iconItem.image = iconImage
        
        let fileItem = NSMenuItem(title: "Select Notes File...", action: #selector(Coordinator.fileAction), keyEquivalent: "")
        fileItem.representedObject = self.fileManager
        fileItem.target = context.coordinator
        
        let fileName = fileManager.getFileName()
        let currentFileItem = NSMenuItem(title: "Current: \(fileName)", action: nil, keyEquivalent: "")
        currentFileItem.isEnabled = false
        // Truncate if too long
        if fileName.count > 30 {
            currentFileItem.title = "Current: \(String(fileName.prefix(27)))..."
        }
        
        let themeItem = NSMenuItem(title: "Change theme", action: #selector(Coordinator.themeAction), keyEquivalent: "")
        themeItem.representedObject = self.themeManager
        themeItem.target = context.coordinator

        let quitItem = NSMenuItem(title: "Quit", action: #selector(Coordinator.quitAction), keyEquivalent: "q")
        quitItem.target = context.coordinator

        nsView.menu?.insertItem(iconItem, at: 0)
        nsView.menu?.insertItem(NSMenuItem.separator(), at: 1)
        nsView.menu?.insertItem(fileItem, at: 2)
        nsView.menu?.insertItem(currentFileItem, at: 3)
        nsView.menu?.insertItem(NSMenuItem.separator(), at: 4)
        nsView.menu?.insertItem(themeItem, at: 5)
        nsView.menu?.insertItem(NSMenuItem.separator(), at: 6)
        nsView.menu?.insertItem(quitItem, at: 7)

        let cell = nsView.cell as? NSButtonCell
        cell?.imagePosition = .imageOnly
        cell?.bezelStyle = .texturedRounded

        nsView.wantsLayer = true
        nsView.layer?.backgroundColor = NSColor.clear.cgColor
        nsView.isBordered = false
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject {
        @objc func quitAction(_ sender: NSMenuItem) {
            NSApplication.shared.terminate(self)
        }
        @objc func themeAction(_ sender: NSMenuItem) {
            let tm = sender.representedObject as! ThemeManager
            tm.showThemeEditor()
        }
        @objc func fileAction(_ sender: NSMenuItem) {
            let fm = sender.representedObject as! NoteFileManager
            _ = fm.selectFile()
            // Notify that file changed - this will trigger reload in TextManager
            NotificationCenter.default.post(name: NSNotification.Name("NoteFileChanged"), object: nil)
        }
    }
}
