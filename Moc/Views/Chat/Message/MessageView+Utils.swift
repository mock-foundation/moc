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
            case .messageVideo(let info):
                makeVideo(from: info)
            case let .messagePhoto(info):
                makePhoto(from: info, contentMode: .fill)
            default:
                EmptyView()
        }
    }
}
