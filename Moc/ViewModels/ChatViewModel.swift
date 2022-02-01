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

class ChatViewModel: ObservableObject {
    @Injected private var dataSource: ChatService

    // MARK: - UI state

    @Published var inputMessage = ""
    @Published var isInspectorShown = false
    @Published var messages: [Message] = []

    @Published var chatTitle = "mock"
    @Published var chatMemberCount: Int?
    
    func update(chat: Chat) async throws {
        dataSource.set(chat: chat)
        objectWillChange.send()
        chatTitle = chat.title
        let memberCount = try await dataSource.chatMemberCount
        let messageHistory = try await dataSource.messageHistory
        DispatchQueue.main.async {
            self.chatMemberCount = memberCount
            self.objectWillChange.send()
            self.messages = messageHistory
        }
    }
}
