//
//  AsyncTdQuickLookView.swift
//  Moc
//
//  Created by Егор Яковенко on 20.06.2022.
//

import SwiftUI
import TDLibKit
import Utilities
import Logs

struct AsyncTdQuickLookView: View {
    let id: Int
    
    var body: some View {
        AsyncTdFile(id: id) { file in
            #if os(macOS)
            if #available(macOS 13, *) {
                QuickLookView(url: URL(filePath: file.local.path))
            } else {
                QuickLookView(url: URL(fileURLWithPath: file.local.path))
            }
            #elseif os(iOS)
            if #available(iOS 16, *) {
                QuickLookPreviewWrapper(items: .constant([
                    QuickLookPreviewItem(url: URL(filePath: file.local.path), title: "")
                ]), index: .constant(0))
            } else {
                QuickLookPreviewWrapper(items: .constant([
                    QuickLookPreviewItem(url: URL(fileURLWithPath: file.local.path), title: "")
                ]), index: .constant(0))
            }
            #endif
        } placeholder: {
            EmptyView()
        }
    }
}
