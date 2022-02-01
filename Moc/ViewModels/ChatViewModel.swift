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
import SystemUtils
import TDLibKit

class ChatViewModel: ObservableObject {
    @Injected private var service: ChatService

    // MARK: - UI state

    @Published var inputMessage = ""
    @Published var isInspectorShown = false
    @Published var messages: [Message] = []

    @Published var chatTitle = "mock"
    @Published var chatMemberCount: Int?

    func update(chat: Chat) async throws {
        service.set(chatId: chat.id)
        objectWillChange.send()
        chatTitle = chat.title
        let memberCount = try await service.chatMemberCount
        let messageHistory: [Message] = try await service.messageHistory.map { tdMessage in
            switch tdMessage.senderId {
            case let .messageSenderUser(user):
                let user = try self.service.getUser(byId: user.userId)
                return Message(
                    id: tdMessage.id,
                    sender: .init(
                        name: "\(user.firstName) \(user.lastName)",
                        type: .user,
                        id: user.id
                    ),
                    content: MessageContent(tdMessage.content),
                    isOutgoing: tdMessage.isOutgoing
                )
            case let .messageSenderChat(chat):
                let chat = try self.service.getChat(id: chat.chatId)
                return Message(
                    id: tdMessage.id,
                    sender: .init(
                        name: chat.title,
                        type: .chat,
                        id: chat.id
                    ),
                    content: MessageContent(tdMessage.content),
                    isOutgoing: tdMessage.isOutgoing
                )
            }
        }

        DispatchQueue.main.async {
            self.chatMemberCount = memberCount
            self.objectWillChange.send()
            self.messages = messageHistory
        }
    }
}
