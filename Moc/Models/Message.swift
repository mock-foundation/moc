//
//  Message.swift
//
//
//  Created by Егор Яковенко on 01.02.2022.
//

import Foundation
import TDLibKit

struct Message: Identifiable, Hashable, Equatable {
    let id: Int64
    let sender: MessageSender
    let content: MessageContent
    let isOutgoing: Bool
    let date: Foundation.Date
    let mediaAlbumID: Int64
    let replyToMessage: ReplyMessage?
    
    init(
        id: Int64,
        sender: MessageSender,
        content: MessageContent,
        isOutgoing: Bool,
        date: Foundation.Date,
        mediaAlbumID: Int64,
        replyToMessage: ReplyMessage? = nil
    ) {
        self.id = id
        self.sender = sender
        self.content = content
        self.isOutgoing = isOutgoing
        self.date = date
        self.mediaAlbumID = mediaAlbumID
        self.replyToMessage = replyToMessage
    }
}
