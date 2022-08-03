//
//  MockChatService.swift
//
//
//  Created by Егор Яковенко on 18.01.2022.
//

import Resolver
import TDLibKit
import Foundation
import Combine

// swiftlint:disable all
public class MockChatService: ChatService {
    public var updateSubject = PassthroughSubject<Update, Never>()

    public func getMessage(by id: Int64) async throws -> TDLibKit.Message {
        return Message(
            authorSignature: "",
            canBeDeletedForAllUsers: false,
            canBeDeletedOnlyForSelf: false,
            canBeEdited: false,
            canBeForwarded: false,
            canBeSaved: false,
            canGetAddedReactions: false,
            canGetMediaTimestampLinks: false,
            canGetMessageThread: false,
            canGetStatistics: false,
            canGetViewers: false,
            chatId: 0,
            containsUnreadMention: false,
            content: .text(.init(text: .init(entities: [], text: ""), webPage: nil)),
            date: 0,
            editDate: 0,
            forwardInfo: nil,
            hasTimestampedMedia: false,
            id: 0,
            interactionInfo: nil,
            isChannelPost: false,
            isOutgoing: false,
            isPinned: false,
            mediaAlbumId: 0,
            messageThreadId: 0,
            replyInChatId: 0,
            replyMarkup: nil,
            replyToMessageId: 0,
            restrictionReason: "",
            schedulingState: nil,
            senderId: .chat(.init(chatId: 0)),
            sendingState: nil,
            ttl: 0,
            ttlExpiresIn: 0,
            unreadReactions: [],
            viaBotUserId: 0)
    }
    
    public func sendMedia(_ url: URL, caption: String) async throws {
        
    }
    
    public func sendAlbum(_ urls: [URL], caption: String) async throws {
        
    }
    
    public var isChannel: Bool = false
    
    public func setAction(_ action: ChatAction) async throws {
        
    }
    
    public func sendMessage(_ message: String) async throws {
        
    }
    
    public var chatPhoto: File?
    
    public func getUser(by id: Int64) async throws -> User {
        User(
            addedToAttachmentMenu: false,
            firstName: "First",
            haveAccess: true,
            id: id,
            isContact: true,
            isFake: false,
            isMutualContact: true,
            isPremium: true,
            isScam: false,
            isSupport: true,
            isVerified: true,
            languageCode: "UA",
            lastName: "Last",
            phoneNumber: "phone",
            profilePhoto: nil,
            restrictionReason: "",
            status: .empty,
            type: .regular,
            username: "username"
        )
    }

    public func getChat(by id: Int64) async throws -> Chat {
        Chat.mock
    }

    public init() {}
    public var messageHistory: [Message] = []

    public var draftMessage: DraftMessage?

    public func set(draft _: DraftMessage?) async throws {}

    public var chatId: Int64? = 0

    public var chatTitle: String = "Ninjas from the Reeds"

    public var chatType: ChatType = .supergroup(.init(isChannel: false, supergroupId: 0))

    public var chatMemberCount: Int? = 20

    public var protected: Bool = false

    public var blocked: Bool = false

    public func set(chatId _: Int64) {}

    public func set(protected _: Bool) async throws {}

    public func set(blocked _: Bool) async throws {}

    public func set(chatTitle _: String) async throws {}
}
