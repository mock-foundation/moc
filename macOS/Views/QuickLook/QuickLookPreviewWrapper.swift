//
//  QuickLook.swift
//  Moc
//
//  Created by Егор Яковенко on 20.06.2022.
//

import SwiftUI
import Quartz

struct QuickLookPreviewWrapper: NSViewRepresentable {
    typealias NSViewType = QLPreviewView
    
    /// URL of a resource to preview
    let url: URL
    
    func makeNSView(context: Context) -> NSViewType {
        let view = QLPreviewView()
        view.autostarts = true
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.previewItem = url as QLPreviewItem
        nsView.refreshPreviewItem()
    }
}
