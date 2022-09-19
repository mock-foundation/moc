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
    private var tdApi: TdApi = .shared
    private var members = [ChatMember]()
    private var chat: Chat?

    var loadedUsers = 0
    var loadingUsers = false

    @Published var chatPhoto: File?
    @Published var chatTitle = ""
    @Published var chatMemberCount: Int? 
    @Published var chatMembers = [User]()
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
        self.chat = try await service.getChat(with: chatId)
        guard let chat else { return }

        DispatchQueue.main.async {
            self.chatPhoto = chat.photo?.big
            self.chatTitle = chat.title
            self.chatMembers = []
        }

        self.loadedUsers = 0
        try await loadMembers(isInitial: true)
    }

    func loadMembers(isInitial: Bool = false) async throws {
        guard let chat else { return }

        if !loadingUsers {
            self.loadingUsers = true
        } else {
            return
        }

        switch chat.type {
            case .basicGroup(let basicGroup):
                if isInitial {
                    let info = try await tdApi.getBasicGroupFullInfo(basicGroupId: basicGroup.basicGroupId)
                    self.members = info.members

                    DispatchQueue.main.async {
                        self.chatMemberCount = self.members.count
                    }

                    try await loadChatMembers(isInitial: isInitial)
                } else {
                    break
                }
            case .supergroup(let supergroup):
                if isInitial {
                    let info = try await tdApi.getSupergroupFullInfo(supergroupId: supergroup.supergroupId)
                    DispatchQueue.main.async {
                        self.chatMemberCount = info.memberCount
                    }
                }

                if self.chatMemberCount == loadedUsers { break }

                let supergroupMembers = try await tdApi.getSupergroupMembers(
                    filter: nil,
                    limit: 10,
                    offset: loadedUsers,
                    supergroupId: supergroup.supergroupId
                )

                self.members = supergroupMembers.members
                loadedUsers += self.members.count

                try await loadChatMembers(isInitial: isInitial)
            default:
                break
        }
    }

    private func loadChatMembers(isInitial: Bool = false) async throws {
        let mappedUsers = try await self.members.asyncCompactMap { member in
            switch member.memberId {
                case .user(let sender):
                    let user = try await tdApi.getUser(userId: sender.userId)
                    return user
                default:
                    return nil
            }
        }

        DispatchQueue.main.async {
            self.chatMembers += mappedUsers
        }
        
        self.loadingUsers = false
    }
}
