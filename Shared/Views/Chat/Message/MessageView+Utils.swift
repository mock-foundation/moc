//
//  MessageView+Utils.swift
//  Moc
//
//  Created by Егор Яковенко on 21.06.2022.
//

import SwiftUI
import TDLibKit

extension MessageView {
    func getPhoto(from content: MessageContent) -> MessagePhoto? {
        if case .photo(let info) = content {
            return info
        } else {
            return nil
        }
    }
    
    func getVideo(from content: MessageContent) -> MessageVideo? {
        if case .video(let info) = content {
            return info
        } else {
            return nil
        }
    }
    
    /// A helper function for displaying a video or a photo media file, depending on the message
    /// content.
    /// - Parameter content: Message content to display
    @ViewBuilder func makeMedia(from content: MessageContent) -> some View {
        switch content {
            case let .video(info):
                makeVideo(from: info)
            case let .photo(info):
                makePhoto(from: info, contentMode: .fill)
            case let .document(info):
                makeDocument(from: info)
            default:
                EmptyView()
        }
    }
    
    /// Returns a caption from the specified message content.
    /// - Parameter content: Where to get the caption from.
    /// - Returns: The resulting caption.
    func getCaption(from content: MessageContent) -> FormattedText {
        switch content {
            case let .text(info):
                return info.text
            case let .animation(info):
                return info.caption
            case let .audio(info):
                return info.caption
            case let .document(info):
                return info.caption
            case let .photo(info):
                return info.caption
            case let .video(info):
                return info.caption
            default:
                return FormattedText(entities: [], text: "")
        }
    }
}

extension MessageContent {
    /// Says whether a message is graphic (photo or video)
    var isGraphic: Bool {
        switch self {
            case .video:
                return true
            case .photo:
                return true
            default:
                return false
        }
    }
}
