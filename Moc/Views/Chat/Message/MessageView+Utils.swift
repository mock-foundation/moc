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
        if case .messagePhoto(let info) = content {
            return info
        } else {
            return nil
        }
    }
    
    func getVideo(from content: MessageContent) -> MessageVideo? {
        if case .messageVideo(let info) = content {
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
            case let .messageVideo(info):
                makeVideo(from: info)
            case let .messagePhoto(info):
                makePhoto(from: info, contentMode: .fill)
            case let .messageDocument(info):
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
            case let .messageText(info):
                return info.text
            case let .messageAnimation(info):
                return info.caption
            case let .messageAudio(info):
                return info.caption
            case let .messageDocument(info):
                return info.caption
            case let .messagePhoto(info):
                return info.caption
            case let .messageVideo(info):
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
            case .messageVideo(_):
                return true
            case .messagePhoto(_):
                return true
            default:
                return false
        }
    }
}
