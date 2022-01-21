//
//  ChatDataRepository.swift
//  
//
//  Created by Егор Яковенко on 18.01.2022.
//
import Combine
import TDLibKit

public protocol ChatDataRepository {
    // MARK: - Messages
    var messageHistory: [Message] { get async throws }
    var draftMessage: DraftMessage? { get async throws }
    func set(draft: DraftMessage?) async throws
    // MARK: - Chat info
    /// `nil` when nothing to show
    var chatId: Int64? { get async throws }
    var chatTitle: String { get async throws }
    var chatType: ChatType { get async throws }
    /// Can be nil if it is a secret/private chat. If nil, a user status (online, offline,
    /// last seen a minute ago etc) will be displayed.
    var chatMemberCount: Int? { get async throws }
    /// Whether content from the chat can't be forwarded, saved locally, or copied.
    var protected: Bool { get async throws }
    /// True, if the chat is blocked by the current user and private messages from
    /// the chat can’t be received.
    var blocked: Bool { get async throws }
    /// Use a provided `Chat` instance to fill variables.
    func set(chat: Chat)
    /// Will work when you have such powers and permissions 😉
    func set(protected: Bool) async throws
    func set(blocked: Bool) async throws
    func set(chatTitle: String) async throws
}
