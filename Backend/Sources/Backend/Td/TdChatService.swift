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

    public var messageHistory: [Backend.Message] {
        get async throws {
            let chatHistory = try await tdApi.getChatHistory(
                chatId: self.chatId,
                fromMessageId: 0,
                limit: 50,
                offset: 0,
                onlyLocal: false
            ).messages ?? []
            return chatHistory.map { tdMessage in
                var type: MessageSenderType
                var id: Int64
                var content: Backend.MessageContent
                var message: Backend.Message = .init(
                    id: 0,
                    sender: .init(
                        name: "",
                        type: .user,
                        id: 0
                    ),
                    content: .unsupported,
                    isOutgoing: false
                )
                switch tdMessage.content {
                    case .messageText(let text):
                        content = .text(text)
                    default:
                        content = .unsupported
                }
                switch tdMessage.senderId {
                    case .messageSenderUser(let user):
                        type = .user
                        id = user.userId
                        try? tdApi.getUser(userId: id) { result in
                            switch result {
                                case .success(let user):
                                    message = Message(
                                        id: 0,
                                        sender: .init(
                                            name: "\(user.firstName) \(user.lastName)",
                                            type: type,
                                            id: user.id
                                        ),
                                        content: content,
                                        isOutgoing: tdMessage.isOutgoing
                                    )
                                case .failure(_):
                                    break
                            }
                        }
                        return Backend.Message(
                            id: 0,
                            sender: .init(
                                name: "Failed to get user",
                                type: type,
                                id: id
                            ),
                            content: content,
                            isOutgoing: false
                        )

                    case .messageSenderChat(let chat):
                        type = .chat
                        id = chat.chatId
                }
                return message
            }
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
