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
    func updateDraft(_ newDraft: DraftMessage?, threadId: Int64?) async throws
    func getUser(by id: Int64) async throws -> User
    func getChat(by id: Int64) async throws -> Chat
    @discardableResult
    func sendTextMessage(_ message: FormattedText, clearDraft: Bool, disablePreview: Bool) async throws -> Message
    @discardableResult
    func sendMedia(_ url: URL, caption: String) async throws -> Message
    @discardableResult
    func sendAlbum(_ urls: [URL], caption: String) async throws -> [Message]?
    func setProtected(_ isProtected: Bool) async throws
    func setBlocked(_ isBlocked: Bool) async throws
    func setChatTitle(_ title: String) async throws
    func setAction(_ action: ChatAction) async throws
    func getMessage(by id: Int64) async throws -> Message
    func getMessageHistory() async throws -> [Message]
    
    var chatId: Int64? { get set }
}
