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
import Algorithms
import Collections
import SwiftUI
import Logs
import AVKit

class ChatViewModel: ObservableObject {
    @Injected var service: any ChatService
    
    var scrollViewProxy: ScrollViewProxy?
    
    @Published var isScrollToBottomButtonShown = true
    @Published var isInspectorShown = false
    @Published var isHideKeyboardButtonShown = false
    @Published var isDroppingMedia = false
    @Published var inputMessage = "" {
        didSet {
            if inputMessage.isEmpty {
                self.updateDraft() // instantly update the draft when the input field is empty
            }
            inputMessageSubject.send(inputMessage)
        }
    }
    @Published var inputMedia: [URL] = []
    @Published var messages: [[Message]] = []
    @Published var highlightedMessageId: Int64?

    @Published var chatID: Int64 = 0
    @Published var chatTitle = ""
    @Published var chatPhoto: File?
    @Published var isChannel = false
    
    var subscribers = Set<AnyCancellable>()
    var logger = Logs.Logger(category: "UI", label: "ChatViewModel")
    var inputMessageSubject = CurrentValueSubject<String, Never>("")
        
    init() {
        service.updateSubject
            .receive(on: RunLoop.main)
            .sink { [self] update in
                // It's a switch-case because it will obviously grow in the future
                switch update {
                    case let .newMessage(info):
                        updateNewMessage(info)
                    default: break
                }
            }
            .store(in: &subscribers)
        SystemUtils.ncPublisher(for: .openChatWithId)
            .sink { notification in
                self.logger.debug("Got openChatWithId notification")
                guard let chatId = notification.object as? Int64 else { return }
                self.logger.debug("Got chat ID from notification")
                                
                Task {
                    try await self.update(chat: try await TdApi.shared.getChat(chatId: chatId))
                }
            }
            .store(in: &subscribers)
        SystemUtils.ncPublisher(for: .openChatWithInstance)
            .sink { notification in
                self.logger.debug("Got openChatWithInstance notification")
                guard let chat = notification.object as? Chat else { return }
                self.logger.debug("Got Chat objected")

                Task {
                    try await self.update(chat: chat)
                }
            }
            .store(in: &subscribers)
        inputMessageSubject
            .debounce(for: .seconds(3), scheduler: RunLoop.main)
            .sink { value in
                self.logger.debug("Processing input message value update: \(value)")
                self.updateAction(with: .typing)
                self.updateDraft()
            }
            .store(in: &subscribers)
    }
    
    deinit {
        for subscriber in subscribers {
            subscriber.cancel()
        }
    }
    
    // swiftlint:disable function_body_length
    func update(chat: Chat) async throws {
        service.chatId = chat.id
        DispatchQueue.main.async { [self] in
            chatID = chat.id
            objectWillChange.send()
            chatTitle = chat.title
        }
        
        let buffer = try await service.getMessageHistory()
            .asyncMap { tdMessage in
                logger.debug("Processing message \(tdMessage.id), mediaAlbumId: \(tdMessage.mediaAlbumId.rawValue)")
                var replyMessage: ReplyMessage?
                let id = tdMessage.replyToMessageId
                if id != 0 {
                    let tdReplyMessage = try await self.service.getMessage(by: id)
                    switch tdReplyMessage.senderId {
                        case let .user(user):
                            let user = try await self.service.getUser(by: user.userId)
                            replyMessage = ReplyMessage(
                                id: id,
                                sender: MessageSender(
                                    firstName: user.firstName,
                                    lastName: user.lastName,
                                    type: .user,
                                    id: user.id),
                                content: tdReplyMessage.content)
                        case let .chat(chat):
                            let chat = try await self.service.getChat(by: chat.chatId)
                            replyMessage = ReplyMessage(
                                id: id,
                                sender: MessageSender(
                                    firstName: chat.title,
                                    lastName: nil,
                                    type: .chat,
                                    id: chat.id),
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
            .map(Array.init(_:))
        
        logger.debug("Chunked message history, length: \(messageHistory.count)")

        DispatchQueue.main.async {
            self.chatPhoto = chat.photo?.small
            switch chat.type {
                case let .supergroup(info):
                    self.isChannel = info.isChannel
                default: self.isChannel = false
            }
            self.messages = messageHistory
            self.scrollToEnd()
        }
    }
}
