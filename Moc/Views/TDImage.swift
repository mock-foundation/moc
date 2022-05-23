//
//  TDImage.swift
//  Moc
//
//  Created by Егор Яковенко on 22.05.2022.
//

import SwiftUI
import TDLibKit
import Utils

struct TDImage: View {
    @State var file: File
    
    @State private var downloadingComplete: Bool
    
    init(file: File) {
        self.file = file
        self.downloadingComplete = file.local.isDownloadingCompleted
        
        if !file.local.isDownloadingCompleted {
            Task {
                try await TdApi.shared[0].downloadFile(
                    fileId: file.id,
                    limit: 0,
                    offset: 0,
                    priority: 12,
                    synchronous: false
                )
            }
        }
    }
    
    @ViewBuilder
    var body: some View {
        Group {
            if downloadingComplete {
                Image(file: file)
                    .resizable()
                    .antialiased(true)
            } else {
                Image()
                    .resizable()
                    .antialiased(true)
            }
        }
        .onReceive(SystemUtils.ncPublisher(for: .updateFile)) { notification in
            guard notification.object != nil else { return }
            
            // swiftlint:disable force_cast
            // I would easily disable it because it will definetely
            // have an UpdateFile as the notification object
            let update = notification.object as! UpdateFile
            
            if update.file.id == file.id {
                self.downloadingComplete = update.file.local.isDownloadingCompleted
            }
        }
    }
}

struct TDImage_Previews: PreviewProvider {
    static var previews: some View {
        Text("No previews for you")
//        TDImage()
    }
}
