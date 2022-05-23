//
//  TdChatService.swift
//
//
//  Created by Егор Яковенко on 18.01.2022.
//

import Combine
import Foundation
import SwiftUI
import Utils
import TDLibKit
import Logging

public class TdChatService: ChatService {
    private var logger = Logging.Logger(label: "Services", category: "TdChatDataSource")
    public var tdApi: TdApi = .shared[0]

    public func set(protected _: Bool) async throws {
        logger.error("set(protected:) not implemented")
    }

    public func getUser(byId: Int64) async throws -> User {
        try await self.tdApi.getUser(userId: byId)
    }

    public func getChat(id: Int64) async throws -> Chat {
        try await self.tdApi.getChat(chatId: id)
    }

    public func getMessageSenderName(_ sender: MessageSender) throws -> String {
        switch sender {
        case let .messageSenderUser(messageSenderUser):
            var str = ""
            try tdApi.getUser(userId: messageSenderUser.userId) { result in
                switch result {
                case let .success(data):
                    str = "\(data.firstName) \(data.lastName)"
                case .failure:
                    str = "Failure"
                }
            }
            return str
        case let .messageSenderChat(messageSenderChat):
            var str = ""
            try tdApi.getChat(chatId: messageSenderChat.chatId) {
                switch $0 {
                case let .success(data):
                    str = data.title
                case .failure:
                    str = "Failure"
                }
            }
            return str
        }
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
            try await tdApi.getChatHistory(
                chatId: chatId,
                fromMessageId: 0,
                limit: 50,
                offset: 0,
                onlyLocal: false
            ).messages ?? []
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

    public func set(chatId: Int64) {
        self.chatId = chatId
        SystemUtils.post(notification: Notification.Name("ChatDataSourceUpdated"))
    }

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
    
    public var chatPhoto: File? {
        get async throws {
            if let photo = try await getChat(id: chatId!).photo {
                return photo.small
            } else {
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
}
