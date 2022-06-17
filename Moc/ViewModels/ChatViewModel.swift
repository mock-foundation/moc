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
import SwiftUI
import Logs

private enum Event {
    case updateNewMessage
}

class ChatViewModel: ObservableObject {
    @Injected private var service: ChatService
    
    #if os(macOS)
    var scrollView: NSScrollView?
    #elseif os(iOS)
    var scrollView: UIScrollView?
    #endif
    var scrollViewProxy: ScrollViewProxy?
    
    // MARK: - UI state

    @Published var inputMessage = ""
    @Published var isInspectorShown = false
    @Published var messages: [Message] = []

    @Published var chatID: Int64 = 0
    @Published var chatTitle = ""
    @Published var chatMemberCount: Int?
    @Published var chatPhoto: File?
    
    private var subscribers: [AnyCancellable] = []
    private var logger = Logs.Logger(label: "ChatViewModel", category: "UI")
    
    init() {
        subscribers.append(SystemUtils.ncPublisher(for: .updateNewMessage)
            .sink(receiveValue: updateNewMessage(notification:)))
//        subscribers.append(contentsOf: SystemUtils.ncPublisher(for: .update))
        
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
            
            switch tdMessage.senderId {
                case let .messageSenderUser(info):
                    let user = try await self.service.getUser(by: info.userId)
                    firstName = user.firstName
                    lastName = user.lastName
                    id = info.userId
                case let .messageSenderChat(info):
                    let chat = try await self.service.getChat(by: info.chatId)
                    firstName = chat.title
                    id = info.chatId
            }
            
            let message = Message(
                id: tdMessage.id,
                sender: MessageSender(
                    name: "\(firstName) \(lastName)",
                    type: .user,
                    id: id),
                content: MessageContent(tdMessage.content),
                isOutgoing: tdMessage.isOutgoing,
                date: Date(timeIntervalSince1970: TimeInterval(tdMessage.date))
            )
            
            DispatchQueue.main.async {
                self.messages.append(message)
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
    
    func update(chat: Chat) async throws {
        service.set(chatId: chat.id)
        DispatchQueue.main.async { [self] in
            chatID = chat.id
            objectWillChange.send()
            chatTitle = chat.title
        }
        let messageHistory: [Message] = try await service.messageHistory
            .asyncMap { tdMessage in
                switch tdMessage.senderId {
                    case let .messageSenderUser(user):
                        let user = try await self.service.getUser(by: user.userId)
                        return Message(
                            id: tdMessage.id,
                            sender: .init(
                                name: "\(user.firstName) \(user.lastName)",
                                type: .user,
                                id: user.id
                            ),
                            content: MessageContent(tdMessage.content),
                            isOutgoing: tdMessage.isOutgoing,
                            date: Date(timeIntervalSince1970: Double(tdMessage.date))
                        )
                    case let .messageSenderChat(chat):
                        let chat = try await self.service.getChat(by: chat.chatId)
                        return Message(
                            id: tdMessage.id,
                            sender: .init(
                                name: chat.title,
                                type: .chat,
                                id: chat.id
                            ),
                            content: MessageContent(tdMessage.content),
                            isOutgoing: tdMessage.isOutgoing,
                            date: Date(timeIntervalSince1970: Double(tdMessage.date))
                        )
                }
            }
            .sorted { $0.id < $1.id }

        DispatchQueue.main.async {
            Task {
                self.objectWillChange.send()
                self.chatPhoto = try await self.service.chatPhoto
                self.chatMemberCount = try await self.service.chatMemberCount
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
    
    func sendMessage(_ message: String) {
        Task {
            try await service.sendMessage(message)
        }
    }
}
