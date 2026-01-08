//
//  HeaderView.swift
//  Notebar
//
//  Created by Jay Stakelon on 1/30/21.
//

import SwiftUI

struct HeaderView: View {
    @ObservedObject var themeManager: ThemeManager
    @Binding var isPreviewMode: Bool
    @ObservedObject var fileManager: NoteFileManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Notebar").font(Font.system(size: 12, weight: .bold, design: .rounded))
                Spacer()
                Button(action: {
                    isPreviewMode.toggle()
                }) {
                    Image(systemName: isPreviewMode ? "pencil" : "eye")
                        .font(.system(size: 12))
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 24, height: 24)
                .help(isPreviewMode ? "Edit Mode" : "Preview Mode")
                DropdownMenuView(themeManager: themeManager, fileManager: fileManager).frame(width: 24, height: 24)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 12)
            Divider().background(Color.gray.opacity(0.1))
        }.background(Color(.windowBackgroundColor))
    }
}
