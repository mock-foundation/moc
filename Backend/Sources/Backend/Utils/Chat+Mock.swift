//
//  Chat+Mock.swift
//  
//
//  Created by Егор Яковенко on 07.07.2022.
//

import TDLibKit

extension Chat {
    static let mock = Chat(
        actionBar: nil,
        availableReactions: [],
        canBeDeletedForAllUsers: true,
        canBeDeletedOnlyForSelf: true,
        canBeReported: true,
        clientData: "",
        defaultDisableNotification: true,
        draftMessage: nil,
        hasProtectedContent: false,
        hasScheduledMessages: false,
        id: 0,
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
            soundId: 0,
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
        type: .private(.init(userId: 0)),
        unreadCount: 0,
        unreadMentionCount: 0,
        unreadReactionCount: 0,
        videoChat: .init(
            defaultParticipantId: nil,
            groupCallId: 0,
            hasParticipants: false
        )
    )
}
