//
//  MessageView+Video.swift
//  Moc
//
//  Created by Егор Яковенко on 24.06.2022.
//

import SwiftUI
import TDLibKit

extension MessageView {
    func makeVideo(from info: MessageVideo) -> some View {
        AsyncTdFileThumbnail(id: info.video.video.id)
            .overlay {
                Button {
                    openedMediaFileID = OpenedMediaFile(id: info.video.video.id, isVideo: true)
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 26))
                        .padding(12)
                }
                .buttonStyle(.plain)
                .background(.ultraThinMaterial, in: Circle())
            }
            .onDrag {
                return NSItemProvider(object: NSURL(fileURLWithPath: info.video.video.local.path))
            }
            .onAppear {
                logger.debug("Video path: \(info.video.video.local.path)")
            }
    }
    
    func makeMessageVideo(from info: MessageVideo) -> some View {
        makeMessage {
            VStack(spacing: 0) {
                makeVideo(from: getVideo(from: message.first!.content)!)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .circular))
                
                if !info.caption.text.isEmpty {
                    Text(info.caption.text)
                        .if(message.first!.isOutgoing) { view in
                            view.foregroundColor(.white)
                        }
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
            }
        }
    }
}
