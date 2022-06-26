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
        AsyncTdVideoPlayer(id: info.video.video.id)
            .frame(minWidth: 0, maxWidth: 350, minHeight: 0, maxHeight: 200)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .circular))
            .onTapGesture {
                openedMediaFileID = OMFID(id: info.video.video.id)
            }
            .onDrag {
                return NSItemProvider(object: NSURL(fileURLWithPath: info.video.video.local.path))
            }
    }
    
    func makeMessageVideo(from info: MessageVideo) -> some View {
        makeMessage {
            VStack(spacing: 0) {
                makeVideo(from: getVideo(from: message.first!.content)!)
                    .frame(height: 200)
                
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
