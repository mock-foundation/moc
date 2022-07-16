//
//  ReplyMessage.swift
//  Moc
//
//  Created by Егор Яковенко on 04.07.2022.
//

import TDLibKit

struct ReplyMessage: Identifiable, Hashable, Equatable {
    let id: Int64
    let sender: String
    let content: MessageContent
    
    init(id: Int64, sender: String, content: MessageContent) {
        self.id = id
        self.sender = sender
        self.content = content
    }
}
