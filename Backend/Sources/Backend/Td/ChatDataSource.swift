//
//  ChatDataSource.swift
//  
//
//  Created by Егор Яковенко on 18.01.2022.
//

import Combine
import TDLibKit
import Logging

public class ChatDataSource: ChatDataSourcable {
    private var logger = Logger(label: "ChatDataSource")

    // MARK: - Messages
    @Published var messageHistory: [Message] = []

    // MARK: - Chat info
    @Published var chatTitle: String = "" {
        didSet {
            Task {
                try await tdApi.setChatTitle(chatId: self.chatId, title: self.chatTitle)
            }
        }
    }
    @Published var draftMessage: DraftMessage? = nil
    @Published var chatId: Int64 = 0
    @Published var chatType: ChatType = .chatTypePrivate(.init(userId: 0))
    @Published var chatMemberCount: Int? = nil
    @Published var protected: Bool = false
    @Published var blocked: Bool = false

    var tdApi: TdApi = .shared[0]

    public init?(chatId: Int64) async {
        self.chatId = chatId
    }

    public func start() async {
        let maybeChatInfo = try? await tdApi.getChat(chatId: chatId)
        guard let chatInfo = maybeChatInfo else {
            logger.error("Failed to get chat info from chatId \(chatId)")
            return
        }
        logger.info("Got chat info")

        self.chatTitle = chatInfo.title
        self.chatType = chatInfo.type
        self.blocked = chatInfo.isBlocked
        switch self.chatType {
            case .chatTypePrivate(_):
                self.chatMemberCount = nil
            case .chatTypeBasicGroup(_):
                let maybeBasicGroup = try? await tdApi.getBasicGroup(basicGroupId: self.chatId)
                guard let basicGroup = maybeBasicGroup else { return }

                self.chatMemberCount = basicGroup.memberCount

                if basicGroup.upgradedToSupergroupId != 0 {
                    self.chatId = basicGroup.upgradedToSupergroupId
                    guard let supegroup = await getSupergroup(chatId: self.chatId) else {
                        logger.error("Failed to get upgraded supergroup from chatId \(self.chatId)")
                        return
                    }
                    self.chatMemberCount = supegroup.memberCount
                }
            case .chatTypeSupergroup(_):
                guard let supegroup = await getSupergroup(chatId: self.chatId) else {
                    logger.error("Failed to get upgraded supergroup from chatId \(self.chatId)")
                    return
                }
                self.chatMemberCount = supegroup.memberCount
            case .chatTypeSecret(_):
                self.chatMemberCount = nil
        }
        self.protected = chatInfo.hasProtectedContent
    }

    private func getSupergroup(chatId: Int64) async -> Supergroup? {
        let maybeSupergroup = try? await tdApi.getSupergroup(supergroupId: chatId)
        guard let supergroup = maybeSupergroup else { return nil }
        return supergroup
    }
}
