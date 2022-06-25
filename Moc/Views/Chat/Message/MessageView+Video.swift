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
        ZStack {
            AsyncTdVideoPlayer(
                id: info.video.video.id
            )
        }
        .frame(minWidth: 0, maxWidth: 350, minHeight: 200)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .circular))
        .onTapGesture {
            openedMediaFileID = OMFID(id: info.video.video.id)
        }
//        .onDrag {
//            let path = info.video.video.local.path
//            if #available(macOS 13.0, *) {
//                #if os(macOS)
//                return NSItemProvider(object: NSImage(contentsOfFile: path)!)
//                #elseif os(iOS)
//                return NSItemProvider(object: UIImage(contentsOfFile: path)!)
//                #endif
//            } else {
//                return NSItemProvider(object: NSURL(fileURLWithPath: path))
//            }
//        }
    }
    
    func makeMessageVideo(from info: MessageVideo) -> some View {
        makeMessage {
            makeVideo(from: getVideo(from: message[0].content)!)
        }
    }
}
