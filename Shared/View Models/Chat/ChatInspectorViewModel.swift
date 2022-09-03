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
    private var logger = Logs.Logger(category: "ChatInspectorViewModel", label: "UI")
    private var subscribers: [AnyCancellable] = []
    @Injected private var service: any ChatInspectorService

    var chatId: Int64
    
    @Published var chatPhoto: File?
    @Published var chatTitle = ""
    @Published var chatMemberCount: Int?
    @Published var selectedInspectorTab: ChatInspectorTab = .users
    
    init(chatId: Int64) {
        self.chatId = chatId
        
        service.updateSubject
            .receive(on: RunLoop.main)
            .sink { update in
                
            }
            .store(in: &subscribers)
    }
}
