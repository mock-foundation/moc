//
//  MockChatDataSource.swift
//  
//
//  Created by Егор Яковенко on 18.01.2022.
//

import TDLibKit
import Resolver

public class MockChatDataSource: ChatDataSource {
    public func setChat(chat: Chat) { }

    public var messageHistory: [Message] = []
    public var draftMessage: DraftMessage?
    public var chatId: Int64?
    public var chatTitle: String = ""
    public var chatType: ChatType = .chatTypePrivate(.init(userId: 0))
    public var chatMemberCount: Int?
    public var protected: Bool = false
    public var blocked: Bool = false
}
