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
    
    typealias NCOutput = NotificationCenter.Publisher.Output

    // MARK: - UI state

    @Published var inputMessage = ""
    @Published var isInspectorShown = false
    @Published var messages: [Message] = []

    @Published var chatTitle = "mock"
    @Published var chatMemberCount: Int?
    
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
    
    func updateNewMessage(notification: NCOutput) {
        let tdMessage = (notification.object as? UpdateNewMessage)!.message
        Task {
            do {
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
            } catch {
                
            }
        }
    }
    
    func update(chat: Chat) async throws {
        service.set(chatId: chat.id)
        objectWillChange.send()
        chatTitle = chat.title
        let memberCount = try await service.chatMemberCount
        let messageHistory: [Message] = try await service.messageHistory.asyncMap { tdMessage in
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
                        date: Date(timeIntervalSince1970: 0)
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
                        date: Date(timeIntervalSince1970: 0)
                    )
            }
        }

        DispatchQueue.main.async {
            self.chatMemberCount = memberCount
            self.objectWillChange.send()
            self.messages = messageHistory
        }
    }

//        .onReceive(SystemUtils.ncPublisher(for: .updateNewMessage)) { notification in

//        }
}
