//
//  ReplyMessage.swift
//  Moc
//
//  Created by Егор Яковенко on 04.07.2022.
//

import TDLibKit

struct ReplyMessage: Hashable, Equatable {
    let sender: String
    let content: FormattedText
    let mediaID: Int64?
    
    init(sender: String, content: FormattedText, mediaID: Int64? = nil) {
        self.sender = sender
        self.content = content
        self.mediaID = mediaID
    }
}
