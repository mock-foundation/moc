//
//  TdChatDataSource.swift
//  
//
//  Created by Егор Яковенко on 18.01.2022.
//

import Combine
import TDLibKit
import Logging

public class TdChatDataSource: ChatDataSource {
    private var logger = Logger(label: "TdChatDataSource")

    // MARK: - Messages
    @Published public var messageHistory: [Message] = []

    // MARK: - Chat info
    @Published public var chatTitle: String = "" {
        didSet {
            Task {
                try await tdApi.setChatTitle(chatId: self.chatId, title: self.chatTitle)
            }
        }
    }
    @Published public var draftMessage: DraftMessage?
    @Published public var chatId: Int64?
    @Published public var chatType: ChatType = .chatTypePrivate(.init(userId: 0))
    @Published public var chatMemberCount: Int?
    @Published public var protected: Bool = false
    @Published public var blocked: Bool = false

    public var tdApi: TdApi = .shared[0]

    public init() {

    }

    public func start() async {
        guard let chatId = chatId else {
            return
        }

        let maybeChatInfo = try? await tdApi.getChat(chatId: self.chatId)
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
                    guard let supegroup = await getSupergroup(chatId: chatId) else {
                        logger.error("Failed to get upgraded supergroup from chatId \(String(describing: self.chatId))")
                        return
                    }
                    self.chatMemberCount = supegroup.memberCount
                }
            case .chatTypeSupergroup(_):
                guard let supegroup = await getSupergroup(chatId: chatId) else {
                    logger.error("Failed to get upgraded supergroup from chatId \(String(describing: self.chatId))")
                    return
                }
                self.chatMemberCount = supegroup.memberCount
            case .chatTypeSecret(_):
                self.chatMemberCount = nil
        }
        self.protected = chatInfo.hasProtectedContent
    }

    /// Just a helper function
    private func getSupergroup(chatId: Int64) async -> Supergroup? {
        let maybeSupergroup = try? await tdApi.getSupergroup(supergroupId: chatId)
        guard let supergroup = maybeSupergroup else { return nil }
        return supergroup
    }

    public func setChat(_ chat: Chat) {
        self.chatId = chat.id
        self.chatType = chat.type
        self.protected = chat.hasProtectedContent
        self.blocked = chat.isBlocked
        self.chatTitle = chat.title
    }
}
