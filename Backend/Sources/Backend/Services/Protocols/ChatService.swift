//
//  ChatService.swift
//
//
//  Created by Егор Яковенко on 18.01.2022.
//

import Combine
import TDLibKit
import Foundation

public protocol ChatService: Service {
    func updateDraft(_ newDraft: DraftMessage?) async throws
    func getUser(by: Int64) async throws -> User
    func getChat(by: Int64) async throws -> Chat
    func sendMessage(_ message: String) async throws
    func sendMedia(_ url: URL, caption: String) async throws
    func sendAlbum(_ urls: [URL], caption: String) async throws
    func setProtected(_ isProtected: Bool) async throws
    func setBlocked(_ isBlocked: Bool) async throws
    func setChatTitle(_ title: String) async throws
    func setChatId(_ id: Int64) async throws
    func setAction(_ action: ChatAction) async throws
    func getMessage(by id: Int64) async throws -> Message
    
    var messageHistory: [Message] { get }
    var draftMessage: DraftMessage? { get }
    var chatId: Int64 { get }
    var chatTitle: String { get }
    var chatType: ChatType { get }
    var chatPhoto: File? { get }
    var chatMemberCount: Int? { get }
    var protected: Bool { get }
    var blocked: Bool { get }
    var isChannel: Bool { get }
}
