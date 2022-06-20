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

struct AsyncTdImage<Content: View, Placeholder: View>: View {
    let id: Int
    let image: (Image) -> Content
    let placeholder: () -> Placeholder
    
    private let tdApi = TdApi.shared[0]
    private let logger = Logs.Logger(category: "AsyncTdImage", label: "UI")
    
    @State private var file: File?
    @State private var isDownloaded = true
    
    @ViewBuilder
    var body: some View {
        Group {
            if isDownloaded {
                if let file = file {
                    image(Image(file: file))
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
