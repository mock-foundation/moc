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
import Utils
import TDLibKit

private enum Event {
    case updateNewMessage
}

class ChatViewModel: ObservableObject {
    @Injected private var service: ChatService
    
    // MARK: - UI state

    @Published var inputMessage = ""
    @Published var isInspectorShown = false
    @Published var messages: [Message] = []

    @Published var chatID: Int64 = 0
    @Published var chatTitle = ""
    @Published var chatMemberCount: Int?
    @Published var chatPhoto: File?
    
    private var subscribers: [Event: AnyCancellable] = [:]
    
    init() {
        subscribers[.updateNewMessage] = SystemUtils.ncPublisher(for: .updateNewMessage)
            .sink(receiveValue: updateNewMessage(notification:))
    }
    
    deinit {
        for subscriber in subscribers {
            subscriber.value.cancel()
        }
    }
    
    func updateNewMessage(notification: NCPO) {
        let tdMessage = (notification.object as? UpdateNewMessage)!.message
        Task {
//            do {
                let sender = try await self.service.getUser(byId: tdMessage.id)
                let message = Message(
                    id: tdMessage.id,
                    sender: MessageSender(
                        name: "\(sender.firstName) \(sender.lastName)",
                        type: .user,
                        id: sender.id),
                    content: MessageContent(tdMessage.content),
                    isOutgoing: tdMessage.isOutgoing,
                    date: Date(timeIntervalSince1970: TimeInterval(tdMessage.date))
                )
                
                messages.append(message)
                print(message, "bruh")
            } catch {
                print(error, "error happened")
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
    
    func update(chat: Chat) async throws {
        service.set(chatId: chat.id)
        chatID = chat.id
        objectWillChange.send()
        chatTitle = chat.title
        let messageHistory: [Message] = try await service.messageHistory
            .asyncMap { tdMessage in
                switch tdMessage.senderId {
                    case let .messageSenderUser(user):
                        let user = try await self.service.getUser(byId: user.userId)
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
                        let chat = try await self.service.getChat(id: chat.chatId)
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
        }
    }
    
    func sendMessage(_ message: String) {
        Task {
            try await service.sendMessage(message)
        }
    }

//        .onReceive(SystemUtils.ncPublisher(for: .updateNewMessage)) { notification in

//        }
}
