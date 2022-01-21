//
//  TdChatService.swift
//  
//
//  Created by Егор Яковенко on 18.01.2022.
//

import Combine
import TDLibKit
import Logging
import Foundation
import SystemUtils

public class TdChatService: ChatService {
    private var logger = Logger(label: "TdChatDataSource")
    public var tdApi: TdApi = .shared[0]

    public func set(protected: Bool) async throws {
        logger.error("set(protected:) not implemented")
    }

    public func set(blocked: Bool) async throws {
        switch try await chatType {
            case .chatTypePrivate(_):
                _ = try await tdApi.toggleMessageSenderIsBlocked(
                    isBlocked: blocked,
                    senderId: .messageSenderUser(.init(userId: chatId!))
                )
            case .chatTypeSupergroup(_):
                _ = try await tdApi.toggleMessageSenderIsBlocked(
                    isBlocked: blocked,
                    senderId: .messageSenderChat(.init(chatId: chatId!))
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
    public var messageHistory: [Message] = []

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
            return try await tdApi.getChat(chatId: chatId).draftMessage
        }
    }
    public var chatId: Int64?
    public var chatType: ChatType {
        get async throws {
            return try await tdApi.getChat(chatId: chatId).type
        }
    }
    public var chatMemberCount: Int?
    public var protected: Bool {
        get async {
            return true
        }
    }
    public var blocked: Bool {
        get async {
            return true
        }
    }

    public init() { }

    public func set(chat: Chat) {
        self.chatId = chat.id
        SystemUtils.post(notification: Notification.Name("ChatDataSourceUpdated"))
    }
}
