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
    
    #if os(macOS)
    var scrollView: NSScrollView?
    #elseif os(iOS)
    var scrollView: UIScrollView?
    #endif
    var scrollViewProxy: ScrollViewProxy?
    
    // MARK: - UI state

    @Published var isInspectorShown = false
    @Published var isHideKeyboardButtonShown = false
    @Published var isDropping = false
    @Published var inputMessage = ""
    @Published var inputMedia: [URL] = []
    @Published var messages: [[Message]] = []

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
                mediaAlbumID: tdMessage.mediaAlbumId.rawValue
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
//        scrollViewProxy?.scrollTo(messages.last?.id ?? 0)
        #if os(macOS)
        scrollView?.documentView?.scroll(CGPoint(
            x: 0,
            y: scrollView?.documentView?.frame.height ?? 0))
        #elseif os(iOS)
        scrollView?.setContentOffset(CGPoint(
            x: 0,
            y: (scrollView?.contentSize.height ?? 0)
            - (scrollView?.bounds.height ?? 0)
            + (scrollView?.contentInset.bottom ?? 0)),
            animated: true)
        #endif
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
                            mediaAlbumID: tdMessage.mediaAlbumId.rawValue
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
                            mediaAlbumID: tdMessage.mediaAlbumId.rawValue
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
}
