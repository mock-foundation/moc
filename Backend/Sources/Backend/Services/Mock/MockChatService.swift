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
    public func updateDraft(_ newDraft: TDLibKit.DraftMessage?, threadId: Int64?) async throws { }
    
    public func getUser(by id: Int64) async throws -> TDLibKit.User {
        // TODO: Move this to a static `mock` variable
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
    
    public func getChat(by id: Int64) async throws -> TDLibKit.Chat {
        Chat.mock
    }
    
    public func sendTextMessage(_ message: TDLibKit.FormattedText, clearDraft: Bool, disablePreview: Bool) async throws -> TDLibKit.Message {
        Message.mock
    }
    
    public func sendMedia(_ url: URL, caption: String) async throws -> TDLibKit.Message {
        Message.mock
    }
    
    public func sendAlbum(_ urls: [URL], caption: String) async throws -> [TDLibKit.Message]? {
        [Message.mock, Message.mock]
    }
    
    public func setProtected(_ isProtected: Bool) async throws { }
    
    public func setBlocked(_ isBlocked: Bool) async throws { }
    
    public func setChatTitle(_ title: String) async throws { }
    
    public func setAction(_ action: TDLibKit.ChatAction) async throws { }
    
    public func getMessage(by id: Int64) async throws -> TDLibKit.Message {
        Message.mock
    }
    
    public func getMessageHistory() async throws -> [TDLibKit.Message] {
        [Message.mock, Message.mock, Message.mock]
    }
    
    public var chatId: Int64? = 1234567890
    
    public var updateSubject = PassthroughSubject<TDLibKit.Update, Never>()
    
    public init() { }
}
