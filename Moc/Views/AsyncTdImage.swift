//
//  AsyncTdImage.swift
//  Moc
//
//  Created by Егор Яковенко on 18.06.2022.
//

import SwiftUI
import TDLibKit
import Utilities
import Logs

struct AsyncTdImage<Content: View>: View {
    let id: Int
    let image: (Image) -> Content
    
    private let tdApi = TdApi.shared[0]
    private let logger = Logs.Logger(label: "AsyncTdImage", category: "UI")
    
    @State private var file: File?
    @State private var isDownloaded = true
    
    @ViewBuilder
    var body: some View {
        Group {
            if isDownloaded {
                if let file = file {
                    image(Image(file: file))
                } else {
                    ProgressView()
                }
            } else {
                ProgressView()
            }
        }
        .onReceive(SystemUtils.ncPublisher(for: .updateFile)) { notification in
            let update = notification.object as! UpdateFile
            
            logger.debug("Received UpdateFile, ID: \(update.file.id), local ID: \(id), isDownloaded: \(update.file.local.isDownloadingCompleted)")
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
            if let id = id {
                logger.debug("Downloading file \(id)")
                self.file = try await tdApi.downloadFile(
                    fileId: id,
                    limit: 0,
                    offset: 0,
                    priority: 4,
                    synchronous: false)
            } else {
                logger.debug("Downloading file \(String(describing: id))")
                self.file = try await tdApi.downloadFile(
                    fileId: self.id,
                    limit: 0,
                    offset: 0,
                    priority: 4,
                    synchronous: false)
            }
        }
    }
}
