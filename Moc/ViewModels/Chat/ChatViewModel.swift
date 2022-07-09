//
//  ChatViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 20.01.2022.
//

import Backend
import Combine
import Foundation
import Resolver
import Utilities
import TDLibKit
import Algorithms
import Collections
import SwiftUI
import Logs
import AVKit

class ChatViewModel: ObservableObject {
    @Injected var service: ChatService
    
    enum InspectorTab {
        case users
        case media
        case links
        case files
        case voice
    }
    
    var scrollViewProxy: ScrollViewProxy?
    

    @Published var isInspectorShown = false
    @Published var isHideKeyboardButtonShown = false
    @Published var selectedInspectorTab: InspectorTab = .users
    @Published var isDropping = false
    @Published var inputMessage = ""
    @Published var inputMedia: [URL] = []
    @Published var messages: [[Message]] = []
    @Published var highlightedMessageId: Int64?

    @Published var chatID: Int64 = 0
    @Published var chatTitle = ""
    @Published var chatMemberCount: Int?
    @Published var chatPhoto: File?
    @Published var isChannel = false
    
    var subscribers: [AnyCancellable] = []
    var logger = Logs.Logger(category: "ChatViewModel", label: "UI")
    
    init() {
        SystemUtils.ncPublisher(for: .updateNewMessage)
            .sink(receiveValue: updateNewMessage(notification:))
            .store(in: &subscribers)
    }
    
    deinit {
        for subscriber in subscribers {
            subscriber.cancel()
        }
    }
    
    // swiftlint:disable function_body_length
    func update(chat: Chat) async throws {
        service.set(chatId: chat.id)
        DispatchQueue.main.async { [self] in
            chatID = chat.id
            objectWillChange.send()
            chatTitle = chat.title
        }
        
        let buffer = try await service.messageHistory
            .asyncMap { tdMessage in
                logger.debug("Processing message \(tdMessage.id), mediaAlbumId: \(tdMessage.mediaAlbumId.rawValue)")
                var replyMessage: ReplyMessage?
                if let id = tdMessage.replyToMessageId, id != 0 {
                    let tdReplyMessage = try await self.service.getMessage(by: id)
                    switch tdReplyMessage.senderId {
                        case let .user(user):
                            let user = try await self.service.getUser(by: user.userId)
                            replyMessage = ReplyMessage(
                                id: id,
                                sender: "\(user.firstName) \(user.lastName)",
                                content: tdReplyMessage.content)
                        case let .chat(chat):
                            let chat = try await self.service.getChat(by: chat.chatId)
                            replyMessage = ReplyMessage(
                                id: id,
                                sender: chat.title,
                                content: tdReplyMessage.content)
                    }
                }
                switch tdMessage.senderId {
                    case let .user(user):
                        let user = try await self.service.getUser(by: user.userId)
                        return Message(
                            id: tdMessage.id,
                            sender: .init(
                                firstName: user.firstName,
                                lastName: user.lastName,
                                type: .user,
                                id: user.id
                            ),
                            content: tdMessage.content,
                            isOutgoing: tdMessage.isChannelPost ? false : tdMessage.isOutgoing,
                            date: Date(timeIntervalSince1970: Double(tdMessage.date)),
                            mediaAlbumID: tdMessage.mediaAlbumId.rawValue,
                            replyToMessage: replyMessage
                        )
                    case let .chat(chat):
                        let chat = try await self.service.getChat(by: chat.chatId)
                        return Message(
                            id: tdMessage.id,
                            sender: .init(
                                firstName: chat.title,
                                lastName: nil,
                                type: .chat,
                                id: chat.id
                            ),
                            content: tdMessage.content,
                            isOutgoing: tdMessage.isChannelPost ? false : tdMessage.isOutgoing,
                            date: Date(timeIntervalSince1970: Double(tdMessage.date)),
                            mediaAlbumID: tdMessage.mediaAlbumId.rawValue,
                            replyToMessage: replyMessage
                        )
                }
            }
            .sorted { $0.id < $1.id }
        
        logger.debug("Transformed message history, length: \(buffer.count)")
        
        let messageHistory: [[Message]] = buffer
            .chunked(by: {
                if $0.mediaAlbumID == 0 {
                    return false
                } else {
                    return $0.mediaAlbumID == $1.mediaAlbumID
                }
            })
            .map {
                Array($0)
            }
        
        logger.debug("Chunked message history, length: \(messageHistory.count)")

        DispatchQueue.main.async {
            Task {
                self.objectWillChange.send()
                self.chatPhoto = try await self.service.chatPhoto
                self.chatMemberCount = try await self.service.chatMemberCount
                self.isChannel = try await self.service.isChannel
            }
            self.objectWillChange.send()
            self.messages = messageHistory
            self.scrollToEnd()
        }
    }
}
