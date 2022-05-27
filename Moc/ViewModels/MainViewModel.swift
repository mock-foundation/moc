//
//  MainViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 01.01.2022.
//

import Resolver
import SwiftUI
import Utilities
import Combine
import TDLibKit
import Logs
import OrderedCollections

class MainViewModel: ObservableObject {
    // MARK: - Chat lists

    @Published var mainChatList: OrderedSet<Chat> = []
    @Published var archiveChatList: OrderedSet<Chat> = []
    @Published var folderChatLists: [Int: [Chat]] = [:]
    
    /// ID of the filter open. 999999 is the main chat list.
    @Published var selectedChatFilter: Int = 999999 {
        didSet {
            Task {
                try await TdApi.shared[0].loadChats(chatList: .chatListFilter(ChatListFilter(chatFilterId: selectedChatFilter)), limit: nil)
            }
        }
    }
    @Published var chatFilters: OrderedSet<ChatFilterInfo> = []

    @Published var showingLoginScreen = false

    /// For chats that have not received updateChatPosition update, and are waiting for distribution.
    var unorderedChatList: [Chat] = []

    private var publishers: [NSNotification.Name: NotificationCenter.Publisher] = [:]
    private var subscribers: [NSNotification.Name: AnyCancellable] = [:]

    private var logger = Logs.Logger(label: "UI", category: "MainViewModel")

    init() {
        subscribers[.updateChatPosition] = SystemUtils.ncPublisher(for: .updateChatPosition).sink(
            receiveValue: updateChatPosition(notification:)
        )
        subscribers[.authorizationStateWaitPhoneNumber] = SystemUtils.ncPublisher(
            for: .authorizationStateWaitPhoneNumber)
        .sink(receiveValue: authorization(notification:))
        subscribers[.updateNewChat] = SystemUtils.ncPublisher(for: .updateNewChat)
            .sink(receiveValue: updateNewChat(notification:))
        subscribers[.updateChatFilters] = SystemUtils.ncPublisher(for: .updateChatFilters)
            .sink(receiveValue: updateChatFilters(_:))
    }
    
    func updateChatFilters(_ notification: NCPO) {
        let update = notification.object as! UpdateChatFilters
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.chatFilters = OrderedSet(update.chatFilters)
        }
        
        print(update.chatFilters, chatFilters)
    }

    func updateChatPosition(notification: NCPO) {
        let update = (notification.object as? UpdateChatPosition)!
        let position = update.position
        let chatId = update.chatId

        if self.unorderedChatList.contains(where: { $0.id == chatId }) {
            switch position.list {
                case .chatListMain:
                    let chats = self.unorderedChatList.filter { chat in
                        chat.id == chatId
                    }
                    for chat in chats {
                        self.mainChatList.append(chat)
                    }
                    self.unorderedChatList = self.unorderedChatList.filter {
                        return $0.id != chatId
                    }
                    sortMainChatList()
                case .chatListArchive:
                    let chats = self.unorderedChatList.filter { chat in
                        chat.id == chatId
                    }
                    for chat in chats {
                        self.archiveChatList.append(chat)
                    }
                    self.unorderedChatList = self.unorderedChatList.filter {
                        return $0.id != chatId
                    }
                    sortArchiveChatList()
                default:
                    break
            }
        }
    }

    func authorization(notification: NCPO) {
        showingLoginScreen = true
    }

    func updateNewChat(notification: NCPO) {
        guard notification.object != nil else {
            return
        }
        let chat: Chat = (notification.object as? UpdateNewChat)!.chat

        let hasChat = unorderedChatList.contains(where: {
            $0.id == chat.id
        })

        if !hasChat {
            unorderedChatList.append(chat)
        }
    }

    deinit {
        for subscriber in subscribers {
            subscriber.value.cancel()
        }
    }

    private func sortMainChatList() {
        mainChatList.sort {
            if !$0.positions.isEmpty, !$1.positions.isEmpty {
                return $0.positions[0].order.rawValue > $1.positions[0].order.rawValue
            } else {
                return true
            }
            //            if $0.lastMessage?.date ?? 1 > $1.lastMessage?.date ?? 0 {
            //                return true
            //            } else {
            //                return false
            //            }
        }
    }

    private func sortArchiveChatList() {
        archiveChatList.sort {
            if !$0.positions.isEmpty, !$1.positions.isEmpty {
                return $0.positions[0].order.rawValue > $1.positions[0].order.rawValue
            } else {
                return true
            }
        }
    }
}
