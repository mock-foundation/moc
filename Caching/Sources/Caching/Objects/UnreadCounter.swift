//
//  UnreadCounter.swift
//  
//
//  Created by Егор Яковенко on 05.06.2022.
//

import GRDB

public struct UnreadCounter: Codable, FetchableRecord, PersistableRecord {
    public var chats: Int
    public var messages: Int
    public var chatList: ChatList
    
    public init(
        chats: Int,
        messages: Int,
        chatList: ChatList
    ) {
        self.chats = chats
        self.messages = messages
        self.chatList = chatList
    }
}
