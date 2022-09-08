//
//  ChatInspectorViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 02.09.2022.
//

import SwiftUI
import Combine
import Backend
import Resolver
import Logs

class ChatInspectorViewModel: ObservableObject {
    private var logger = Logs.Logger(category: "UI", label: "ChatInspectorViewModel")
    private var subscribers: [AnyCancellable] = []
    @Injected private var service: any ChatInspectorService

    var chatId: Int64 {
        didSet {
            Task {
                do {
                    try await updateInfo()
                } catch {
                    logger.error("Got error: \(error)")
                }
            }
        }
    }
    
    @Published var chatPhoto: File?
    @Published var chatTitle = ""
    @Published var chatMemberCount: Int?
    @Published var selectedInspectorTab: ChatInspectorTab = .users
    
    init(chatId: Int64) {
        self.chatId = chatId

        Task { try await updateInfo() }
        
        service.updateSubject
            .receive(on: RunLoop.main)
            .sink { update in
                switch update {
                    case let .chatPhoto(info):
                        if info.chatId == chatId {
                            self.chatPhoto = info.photo?.big
                        }
                    case let .chatTitle(info):
                        if info.chatId == chatId {
                            self.chatTitle = info.title
                        }
                    default: break
                }
            }
            .store(in: &subscribers)
    }
    
    func updateInfo() async throws {
        let chat = try await service.getChat(with: chatId)
        DispatchQueue.main.async {
            self.chatPhoto = chat.photo?.big
            self.chatTitle = chat.title
        }
    }
}
