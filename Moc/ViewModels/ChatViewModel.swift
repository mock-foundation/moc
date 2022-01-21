//
//  ChatViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 20.01.2022.
//

import Foundation
import Backend
import Resolver
import SystemUtils
import TDLibKit
import Combine

class ChatViewModel: ObservableObject {
    @Injected private var dataSource: ChatService
    private var queue: DispatchQueue = .main

    // MARK: - UI state
    @Published var inputMessage = ""
    @Published var isInspectorShown = false

    @Published var chatTitle = "mock"
    @Published var chatMemberCount: Int?

    func update(chat: Chat) async throws {
        dataSource.set(chat: chat)
        self.chatTitle = chat.title
        self.chatMemberCount = try await dataSource.chatMemberCount
    }
}
