//
//  TdChatService.swift
//
//
//  Created by Егор Яковенко on 18.01.2022.
//

import Combine
import Foundation
import Logging
import SystemUtils
import TDLibKit

public class TdChatService: ChatService {
    private var logger = Logger(label: "TdChatDataSource")
    public var tdApi: TdApi = .shared[0]

    public func set(protected _: Bool) async throws {
        logger.error("set(protected:) not implemented")
    }

    public func set(blocked: Bool) async throws {
        switch try await chatType {
        case let .chatTypePrivate(info):
            _ = try await tdApi.toggleMessageSenderIsBlocked(
                isBlocked: blocked,
                senderId: .messageSenderUser(.init(userId: info.userId))
            )
        case let .chatTypeSupergroup(info):
            _ = try await tdApi.toggleMessageSenderIsBlocked(
                isBlocked: blocked,
                senderId: .messageSenderChat(.init(chatId: info.supergroupId))
            )
        default:
            throw ChatServiceError.cantBeBlocked
        }
    }

    public func set(chatTitle: String) async throws {
        _ = try await tdApi.setChatTitle(chatId: chatId, title: chatTitle)
    }

    public func set(draft: DraftMessage?) async throws {
        _ = try await tdApi.setChatDraftMessage(chatId: chatId, draftMessage: draft, messageThreadId: nil)
    }

    // MARK: - Messages

    public var messageHistory: [Message] {
        get async throws {
            let history = try await tdApi.getChatHistory(
                chatId: chatId,
                fromMessageId: 0,
                limit: 50,
                offset: 0,
                onlyLocal: false
            )
            logger.info("Chat history length: \(history.totalCount)")
            return history.messages ?? []
        }
    }

    // MARK: - Chat info

    public var chatTitle: String = "" {
        didSet {
            Task {
                try await tdApi.setChatTitle(chatId: self.chatId, title: self.chatTitle)
            }
        }
    }

    public var draftMessage: DraftMessage? {
        get async throws {
            try await tdApi.getChat(chatId: chatId).draftMessage
        }
    }

    public var chatId: Int64?
    public var chatType: ChatType {
        get async throws {
            try await tdApi.getChat(chatId: chatId).type
        }
    }

    public var chatMemberCount: Int? {
        get async throws {
            switch try await chatType {
            case let .chatTypeBasicGroup(info):
                return try await tdApi.getBasicGroupFullInfo(
                    basicGroupId: info.basicGroupId
                ).members.count
            case let .chatTypeSupergroup(info):
                return try await tdApi.getSupergroupFullInfo(
                    supergroupId: info.supergroupId
                ).memberCount
            default:
                return nil
            }
        }
    }

    public var protected: Bool {
        get async {
            true
        }
    }

    public var blocked: Bool {
        get async {
            true
        }
    }

    public init() {}

    public func set(chat: Chat) {
        chatId = chat.id
        SystemUtils.post(notification: Notification.Name("ChatDataSourceUpdated"))
    }
}
