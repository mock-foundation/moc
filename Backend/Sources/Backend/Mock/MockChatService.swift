//
//  MockChatService.swift
//
//
//  Created by Егор Яковенко on 18.01.2022.
//

import Resolver
import TDLibKit

public class MockChatService: ChatService {
    public func getUser(byId: Int64) throws -> User {
        User(
            firstName: "First",
            haveAccess: true,
            id: byId,
            isContact: true,
            isFake: false,
            isMutualContact: true,
            isScam: false,
            isSupport: true,
            isVerified: true,
            languageCode: "UA",
            lastName: "Last",
            phoneNumber: "phone",
            profilePhoto: nil,
            restrictionReason: "",
            status: .userStatusEmpty,
            type: .userTypeRegular,
            username: "username"
        )
    }

    public func getChat(id: Int64) throws -> Chat {
        Chat(
            actionBar: nil,
            canBeDeletedForAllUsers: true,
            canBeDeletedOnlyForSelf: true,
            canBeReported: true,
            clientData: "",
            defaultDisableNotification: true,
            draftMessage: nil,
            hasProtectedContent: false,
            hasScheduledMessages: false,
            id: id,
            isBlocked: false,
            isMarkedAsUnread: true,
            lastMessage: nil,
            lastReadInboxMessageId: 0,
            lastReadOutboxMessageId: 0,
            messageSenderId: nil,
            messageTtl: 0,
            notificationSettings: .init(
                disableMentionNotifications: true,
                disablePinnedMessageNotifications: true,
                muteFor: 0,
                showPreview: false,
                sound: "",
                useDefaultDisableMentionNotifications: false,
                useDefaultDisablePinnedMessageNotifications: false,
                useDefaultMuteFor: false,
                useDefaultShowPreview: false,
                useDefaultSound: false
            ),
            pendingJoinRequests: nil,
            permissions: .init(
                canAddWebPagePreviews: false,
                canChangeInfo: false,
                canInviteUsers: false,
                canPinMessages: false,
                canSendMediaMessages: false,
                canSendMessages: false,
                canSendOtherMessages: false,
                canSendPolls: true
            ),
            photo: nil,
            positions: [],
            replyMarkupMessageId: 0,
            themeName: "",
            title: "Ayy",
            type: .chatTypePrivate(.init(userId: 0)),
            unreadCount: 0,
            unreadMentionCount: 0,
            videoChat: .init(
                defaultParticipantId: nil,
                groupCallId: 0,
                hasParticipants: false
            )
        )
    }

    public init() {}
    public var messageHistory: [Message] = []

    public func getMessageSenderName(_: MessageSender) throws -> String {
        "Name"
    }

    public var draftMessage: DraftMessage?

    public func set(draft _: DraftMessage?) async throws {}

    public var chatId: Int64? = 0

    public var chatTitle: String = "Ninjas from the Reeds"

    public var chatType: ChatType = .chatTypeSupergroup(.init(isChannel: false, supergroupId: 0))

    public var chatMemberCount: Int? = 20

    public var protected: Bool = false

    public var blocked: Bool = false

    public func set(chatId _: Int64) {}

    public func set(protected _: Bool) async throws {}

    public func set(blocked _: Bool) async throws {}

    public func set(chatTitle _: String) async throws {}
}
