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
    
    var chatList: [Chat] {
        if isArchiveChatListOpen {
            let chats = allChats.filter { chat in
                chatPositions[chat.id]?.list == .chatListArchive
            }
            
            return chats.sorted { previous, next in
                guard let previousPosition = chatPositions[previous.id]?.order else { return false }
                guard let nextPosition = chatPositions[next.id]?.order else { return false }

                return previousPosition > nextPosition
            }
        } else {
            if selectedChatFilter == 999999 {
                let chats = allChats.filter { chat in
                    chatPositions[chat.id]?.list == .chatListMain
                }
                
                return chats.sorted { previous, next in
                    guard let previousPosition = chatPositions[previous.id]?.order else { return false }
                    guard let nextPosition = chatPositions[next.id]?.order else { return false }
                    
                    return previousPosition > nextPosition
                }
            } else {
                let chats = allChats.filter { chat in
                    chatPositions[chat.id]?.list == .chatListFilter(
                        ChatListFilter(chatFilterId: selectedChatFilter))
                }
                
                return chats.sorted { previous, next in
                    guard let previousPosition = chatPositions[previous.id]?.order else { return false }
                    guard let nextPosition = chatPositions[next.id]?.order else { return false }
                    
                    return previousPosition > nextPosition
                }
            }
        }
    }
    
    @Published var allChats: OrderedSet<Chat> = []
    @Published var chatPositions: [Int64: ChatPosition] = [:]
    
    /// ID of the filter open. 999999 is the main chat list.
    @Published var selectedChatFilter: Int = 999999 {
        didSet {
            Task {
                try await TdApi.shared[0].loadChats(
                    chatList: .chatListFilter(.init(chatFilterId: selectedChatFilter)),
                    limit: 30)
            }
        }
    }
    
    @Published var chatFilters: OrderedSet<ChatFilterInfo> = []

    @Published var showingLoginScreen = false
    @Published var isArchiveChatListOpen = false

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
        // swiftlint:disable force_cast
        let update = notification.object as! UpdateChatFilters
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.chatFilters = OrderedSet(update.chatFilters)
        }
    }

    func updateChatPosition(notification: NCPO) {
        let update = (notification.object as? UpdateChatPosition)!
        let position = update.position
        let chatId = update.chatId

        if !chatPositions.contains(where: { (key, value) in
            key == chatId && value == position
        }) {
            chatPositions[chatId] = position
        }
    }

    func updateNewChat(notification: NCPO) {
        guard notification.object != nil else {
            return
        }
        let chat: Chat = (notification.object as? UpdateNewChat)!.chat

        allChats.updateOrAppend(chat)
    }
    
    func authorization(notification: NCPO) {
        showingLoginScreen = true
    }

    deinit {
        for subscriber in subscribers {
            subscriber.value.cancel()
        }
    }
}
