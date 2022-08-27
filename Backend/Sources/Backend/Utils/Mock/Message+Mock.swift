//
//  File.swift
//  
//
//  Created by Егор Яковенко on 27.08.2022.
//

import TDLibKit

public extension Message {
    static let mock = Message(
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
