//
//  ChatServiceKey.swift
//  Moc
//
//  Created by Егор Яковенко on 27.08.2022.
//

import SwiftUI
import Backend

struct ChatServiceKey: EnvironmentKey {
    static let defaultValue: ChatService = MockChatService()
}

extension EnvironmentValues {
    var chatService: ChatService {
        get { self[ChatServiceKey.self] }
        set { self[ChatServiceKey.self] = newValue }
    }
}
