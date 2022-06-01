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
    
    // just a helper function to filter out a set of chat positions
    private func getPosition(from positions: Set<ChatPosition>, chatList: ChatList) -> ChatPosition? {
        return positions.first { position in
            position.list == chatList
        }
    }
    
    private func chats(from chatList: ChatList) -> [Chat] {
        let chats = self.allChats.filter { chat in
            guard let positions = self.chatPositions[chat.id] else { return false }
            return self.getPosition(from: positions, chatList: chatList) != nil
        }
        
        return chats.sorted { previous, next in
            guard let previousPosition = self.getPosition(
                from: self.chatPositions[previous.id] ?? [],
                chatList: chatList)?.order else { return false }
            guard let nextPosition = self.getPosition(
                from: self.chatPositions[next.id] ?? [],
                chatList: chatList)?.order else { return false }
            
            return previousPosition > nextPosition
        }
    }
    
    var chatList: [Chat] {
        if isArchiveChatListOpen {
            return chats(from: .chatListArchive)
        } else {
            if selectedChatFilter == 999999 {
                return chats(from: .chatListMain)
            } else {
                return chats(from: .chatListFilter(.init(chatFilterId: selectedChatFilter)))
            }
        }
    }
    
    @Published var allChats: OrderedSet<Chat> = []
    @Published var chatPositions: [Int64: Set<ChatPosition>] = [:]
    
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
        let update = notification.object as! UpdateChatFilters
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
            withAnimation {
                self.chatFilters = OrderedSet(update.chatFilters)
            }
        }
    }

    func updateChatPosition(notification: NCPO) {
        let update = (notification.object as? UpdateChatPosition)!
        let position = update.position
        let chatId = update.chatId
        
        if !chatPositions.contains(where: { key, value in
            key == chatId && getPosition(from: value, chatList: position.list) == position
        }) {
            withAnimation {
                if chatPositions[chatId] == nil { chatPositions[chatId] = [] }
                
                if chatPositions[chatId]!.contains(position) {
                    objectWillChange.send()
                    chatPositions[chatId]!.update(with: position)
                } else {
                    objectWillChange.send()
                    chatPositions[chatId]!.insert(position)
                }
            }
        }
    }

    func updateNewChat(notification: NCPO) {
        guard notification.object != nil else {
            return
        }
        let chat: Chat = (notification.object as? UpdateNewChat)!.chat

        _ = withAnimation {
            allChats.updateOrAppend(chat)
        }
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
