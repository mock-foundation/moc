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

    @Published var chatTitle = "mock" {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var chatMemberCount: Int? = 1 {
        willSet {
            self.objectWillChange.send()
        }
    }

    func update(chat: Chat) async throws {
        print("Ayyy update")
        self.chatTitle = chat.title
        self.chatMemberCount = try! await dataSource.chatMemberCount
        dataSource.set(chat: chat)
        try await updateVariables()
    }

    private func updateVariables() async throws {
        self.chatTitle = try await dataSource.chatTitle
        self.chatMemberCount = (try await dataSource.chatMemberCount) ?? nil
    }

    init() {
        SystemUtils.ncPublisher(for: Notification.Name("ChatDataSourceUpdated"))
//            .receive(on: RunLoop.main)
            .sink { _ in
                Task {
                    try! await self.updateVariables()
                }
            }
    }
}
