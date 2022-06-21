//
//  AsyncTdQuickLookView.swift
//  Moc
//
//  Created by Егор Яковенко on 21.06.2022.
//

import SwiftUI
import TDLibKit
import Utilities
import Logs
struct AsyncTdQuickLookView<Placeholder: View>: View {
    let id: Int
    let placeholder: () -> Placeholder
    
    private let tdApi = TdApi.shared[0]
    private let logger = Logs.Logger(category: "AsyncTdQuickLook", label: "UI")
    
    @State private var file: File?
    @State private var isDownloaded = true
    
    @ViewBuilder
    var body: some View {
        Group {
            if isDownloaded {
                if let file = file {
                    if #available(macOS 13, iOS 16, *) {
                        QuickLookPreviewWrapper(items: .constant([
                            QuickLookPreviewItem(url: URL(filePath: file.local.path), title: "")
                        ]), index: .constant(0))
                    } else {
                        QuickLookPreviewWrapper(items: .constant([
                            QuickLookPreviewItem(url: URL(fileURLWithPath: file.local.path), title: "")
                        ]), index: .constant(0))
                    }
                } else {
                    placeholder()
                }
            } else {
                placeholder()
            }
        }
        .onReceive(SystemUtils.ncPublisher(for: .updateFile)) { notification in
            let update = notification.object as! UpdateFile
            if update.file.id == id {
                file = update.file
                isDownloaded = update.file.local.isDownloadingCompleted
            }
        }
        .onChange(of: id) { id in
            download(id)
        }
        .onAppear {
            download()
        }
    }
    
    private func download(_ id: Int? = nil) {
        Task {
            logger.debug("Downloading file \(id != nil ? id! : self.id)")
            self.file = try await tdApi.downloadFile(
                fileId: id != nil ? id! : self.id,
                limit: 0,
                offset: 0,
                priority: 4,
                synchronous: false)
        }
    }
}
