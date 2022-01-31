//
//  MockChatService.swift
//
//
//  Created by Егор Яковенко on 18.01.2022.
//

import Resolver
import TDLibKit

public class MockChatService: ChatService {
    public init() {}
    public var messageHistory: [Message] = []

    public func getMessageSenderName(_ sender: MessageSender) throws -> String {
        return "Name"
    }

    public var draftMessage: DraftMessage?

    public func set(draft _: DraftMessage?) async throws {}

    public var chatId: Int64? = 0

    public var chatTitle: String = "Ninjas from the Reeds"

    public var chatType: ChatType = .chatTypeSupergroup(.init(isChannel: false, supergroupId: 0))

    public var chatMemberCount: Int? = 20

    public var protected: Bool = false

    public var blocked: Bool = false

    public func set(chat _: Chat) {}

    public func set(protected _: Bool) async throws {}

    public func set(blocked _: Bool) async throws {}

    public func set(chatTitle _: String) async throws {}
}
