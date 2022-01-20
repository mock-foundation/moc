//
//  ChatViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 20.01.2022.
//

import Foundation
import Backend
import Resolver

class ChatViewModel: ObservableObject {
    @Injected private var dataSource: ChatDataSource

    // MARK: - UI state
    @Published var inputMessage = ""
    @Published var isInspectorShown = false

    @Published var chatTitle = ""
    @Published var chatMemberCount: Int?

    init() {
        Task {
            self.chatTitle = (try? await dataSource.chatTitle) ?? ""
            self.chatMemberCount = (try? await dataSource.chatMemberCount) ?? nil
        }
    }
}
