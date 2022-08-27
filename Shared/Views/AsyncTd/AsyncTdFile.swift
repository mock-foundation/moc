//
//  AsyncTdFile.swift
//  Moc
//
//  Created by Егор Яковенко on 24.06.2022.
//

import SwiftUI
import TDLibKit
import Utilities
import Logs

struct AsyncTdFile<Content: View, Placeholder: View>: View {
    let id: Int
    @ViewBuilder let content: (File) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    
    private let tdApi = TdApi.shared
    private let logger = Logs.Logger(category: "AsyncTdFile", label: "UI")
    
    @State private var file: File?
    @State private var isDownloaded = true
    
    @ViewBuilder
    var body: some View {
        Group {
            if isDownloaded {
                if let file = file {
                    content(file)
                } else {
                    placeholder()
                }
            } else {
                placeholder()
            }
        }
        .transition(.opacity)
        .animation(.easeInOut, value: isDownloaded)
        .animation(.easeInOut, value: file)
        .onReceive(tdApi.client.updateSubject) { update in
            if case let .file(info) = update {
                if info.file.id == id {
                    file = info.file
                    isDownloaded = info.file.local.isDownloadingCompleted
                }
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
            do {
                self.file = try await tdApi.downloadFile(
                    fileId: id != nil ? id! : self.id,
                    limit: 0,
                    offset: 0,
                    priority: 4,
                    synchronous: false)
            } catch {
                logger.error(
                    """
                    Failed to download file with ID \(id != nil ? id! : self.id), \
                    reason: \((error as! TDLibKit.Error).message)
                    """)
            }
        }
    }
}
