//
//  MockChatService.swift
//  
//
//  Created by Егор Яковенко on 18.01.2022.
//

import TDLibKit
import Resolver

public class MockChatService: ChatService {
    public var messageHistory: [Message] = []

    public var draftMessage: DraftMessage?

    public func set(draft: DraftMessage?) async throws {

    }

    public var chatId: Int64? = 0

    public var chatTitle: String = "Ninjas from the Reeds"

    public var chatType: ChatType = .chatTypeSupergroup(.init(isChannel: false, supergroupId: 0))

    public var chatMemberCount: Int? = 20

    public var protected: Bool = false

    public var blocked: Bool = false

    public func set(chat: Chat) {

    }

    public func set(protected: Bool) async throws {

    }

    public func set(blocked: Bool) async throws {

    }

    public func set(chatTitle: String) async throws {

    }
}
