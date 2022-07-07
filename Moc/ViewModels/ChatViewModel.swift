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
    @Injected private var service: ChatService
    
    var scrollViewProxy: ScrollViewProxy?
    
    enum InspectorTab {
        case users
        case media
        case links
        case files
        case voice
    }
    
    // MARK: - UI state

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
    
    private var subscribers: [AnyCancellable] = []
    private var logger = Logs.Logger(category: "ChatViewModel", label: "UI")
    
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
    
    func updateNewMessage(notification: NCPO) {
        logger.debug(notification.name.rawValue)
        let tdMessage = (notification.object as? UpdateNewMessage)!.message
        logger.debug("Message chat ID: \(tdMessage.chatId), Chat ID: \(chatID)")
        guard tdMessage.chatId == chatID else {
            logger.debug("Message not for this chat")
            return
        }
        Task {
            var firstName = ""
            var lastName = ""
            var id: Int64 = 0
            var type: MessageSenderType = .user
            var replyMessage: ReplyMessage?
            
            if let id = tdMessage.replyToMessageId, id != 0 {
                let tdReplyMessage = try await self.service.getMessage(by: id)
                switch tdReplyMessage.senderId {
                    case let .messageSenderUser(user):
                        let user = try await self.service.getUser(by: user.userId)
                        replyMessage = ReplyMessage(
                            id: id,
                            sender: "\(user.firstName) \(user.lastName)",
                            content: tdReplyMessage.content)
                    case let .messageSenderChat(chat):
                        let chat = try await self.service.getChat(by: chat.chatId)
                        replyMessage = ReplyMessage(
                            id: id,
                            sender: chat.title,
                            content: tdReplyMessage.content)
                }
            }
            
            switch tdMessage.senderId {
                case let .messageSenderUser(info):
                    let user = try await self.service.getUser(by: info.userId)
                    firstName = user.firstName
                    lastName = user.lastName
                    id = info.userId
                    type = .user
                case let .messageSenderChat(info):
                    let chat = try await self.service.getChat(by: info.chatId)
                    firstName = chat.title
                    id = info.chatId
                    type = .chat
            }
            
            let message = Message(
                id: tdMessage.id,
                sender: MessageSender(
                    firstName: firstName,
                    lastName: lastName,
                    type: type,
                    id: id),
                content: tdMessage.content,
                isOutgoing: tdMessage.isChannelPost ? false : tdMessage.isOutgoing,
                date: Date(timeIntervalSince1970: TimeInterval(tdMessage.date)),
                mediaAlbumID: tdMessage.mediaAlbumId.rawValue,
                replyToMessage: replyMessage
            )
            
            DispatchQueue.main.async {
                self.messages.append([message])
                self.scrollToEnd()
            }
        }
        
//            .chunked {
//                let firstDay = Calendar.current.dateComponents([.day], from: $0.date).day
//                let secondDay = Calendar.current.dateComponents([.day], from: $1.date).day
//                guard firstDay != nil else { false }
//                guard secondDay != nil else { false }
//
//                return firstDay! < secondDay!
//            }
    }
    
    func scrollToEnd() {
        withAnimation(.timingCurve(0, 0.99, 0.31, 1, duration: 1.5)) {
            scrollViewProxy?.scrollTo(messages.last?.first?.id ?? 0)
        }
    }
    
    func scrollToMessage(at id: Int64) {
        highlightMessage(at: id)
        withAnimation(.timingCurve(0, 0.99, 0.31, 1, duration: 1.5)) {
            scrollViewProxy?.scrollTo(id, anchor: .center)
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
                        case let .messageSenderUser(user):
                            let user = try await self.service.getUser(by: user.userId)
                            replyMessage = ReplyMessage(
                                id: id,
                                sender: "\(user.firstName) \(user.lastName)",
                                content: tdReplyMessage.content)
                        case let .messageSenderChat(chat):
                            let chat = try await self.service.getChat(by: chat.chatId)
                            replyMessage = ReplyMessage(
                                id: id,
                                sender: chat.title,
                                content: tdReplyMessage.content)
                    }
                }
                switch tdMessage.senderId {
                    case let .messageSenderUser(user):
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
                    case let .messageSenderChat(chat):
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
    
    func updateAction(with action: ChatAction) {
        Task {
            try await service.setAction(action)
        }
    }
    
    func updateDraft() {
        Task {
            try await service.set(draft: .init(
                date: Int(Date.now.timeIntervalSince1970),
                inputMessageText: .inputMessageText(.init(
                    clearDraft: true,
                    disableWebPagePreview: false,
                    text: .init(entities: [], text: inputMessage))),
                replyToMessageId: 0))
        }
    }
    
    func sendMessage() {
        Task {
            do {
                if inputMedia.isEmpty {
                    try await service.sendMessage(inputMessage)
                } else {
                    if inputMedia.count > 1 {
                        try await service.sendAlbum(inputMedia, caption: inputMessage)
                    } else {
                        try await service.sendMedia(inputMedia.first!, caption: inputMessage)
                    }
                }
                DispatchQueue.main.async { [self] in
                    inputMessage = ""
                    inputMedia.removeAll()
                    scrollToEnd()
                }
            } catch {
                let tdError = error as! TDLibKit.Error
                logger.error("Code: \(tdError.code), message: \(tdError.message)")
            }
        }
    }
    
    func highlightMessage(at id: Int64) {
        highlightedMessageId = id
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.highlightedMessageId = nil
        }
    }
}
