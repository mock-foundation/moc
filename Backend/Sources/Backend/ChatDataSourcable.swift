//
//  ChatDataSourcable.swift
//  
//
//  Created by Егор Яковенко on 18.01.2022.
//
import Combine
import TDLibKit

public protocol ChatDataSourcable: ObservableObject, DataSourcable {
    // MARK: - Messages
    var messageHistory: [Message] { get }
    var draftMessage: DraftMessage? { get set }

    // MARK: - Chat info
    /// `nil` when nothing to show
    var chatId: Int64? { get }
    var chatTitle: String { get set }
    var chatType: ChatType { get }
    /// Can be nil if it is a secret/private chat. If nil, a user status (online, offline,
    /// last seen a minute ago etc) will be displayed.
    var chatMemberCount: Int? { get }
    /// Whether content from the chat can't be forwarded, saved locally, or copied.
    /// The `set` method will work when you have such powers and permissions 😉
    var protected: Bool { get set }
    /// True, if the chat is blocked by the current user and private messages from
    /// the chat can’t be received.
    var blocked: Bool { get set }
}
