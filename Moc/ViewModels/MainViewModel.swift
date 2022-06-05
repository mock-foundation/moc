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
import Backend

class MainViewModel: ObservableObject {
    @Injected var service: MainService
        
    // just a helper function to filter out a set of chat positions
    private func getPosition(from positions: [ChatPosition], chatList: ChatList) -> ChatPosition? {
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
    @Published var chatPositions: [Int64: [ChatPosition]] = [:]
    
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
    
    // TODO: Add a new array/set for unread counters
    @Published var chatFilters: OrderedSet<Backend.ChatFilter> = []

    @Published var showingLoginScreen = false
    @Published var isArchiveChatListOpen = false

    private var subscribers: [AnyCancellable] = []
    private var logger = Logs.Logger(label: "UI", category: "MainViewModel")

    init() {
        if let filters = try? service.getFilters() {
            logger.debug("Filling chat filter with cached ones: \(filters)")
            chatFilters = OrderedSet(filters)
            logger.trace("\(filters.count), \(chatFilters.count)")
        } else {
            logger.debug("There was an issue retrieving cached chat filters, using empty array")
            chatFilters = []
        }
        addSubscriber(for: .updateChatPosition, action: updateChatPosition(_:))
        addSubscriber(for: .authorizationStateWaitPhoneNumber, action: authorization(_:))
        addSubscriber(for: .updateNewChat, action: updateNewChat(_:))
        addSubscriber(for: .updateChatFilters, action: updateChatFilters(_:))
        addSubscriber(for: .updateUnreadChatCount, action: updateUnreadChatCount(_:))
        addSubscriber(for: .updateChatLastMessage, action: updateChatLastMessage(_:))
        addSubscriber(for: .updateChatDraftMessage, action: updateChatDraftMessage(_:))
    }
    
    func addSubscriber(for notification: NSNotification.Name, action: @escaping ((NCPO) -> Void)) {
        subscribers.append(SystemUtils.ncPublisher(for: notification)
            .receive(on: RunLoop.main)
            .sink(receiveValue: action))
    }
    
    func updateUnreadChatCount(_ notification: NCPO) {
        let update = notification.object as! UpdateUnreadChatCount
        // TODO: Rewrite the unread counters logic
    }
    
    func updateChatFilters(_ notification: NCPO) {
        let update = notification.object as! UpdateChatFilters
        logger.debug("Chat filter update")
        
        // TODO: Update chat filters logic

        DispatchQueue.main.async { [self] in
            withAnimation {
                for chatFilter in update.chatFilters {
                    let newData = Backend.ChatFilter(
                        title: chatFilter.title,
                        id: chatFilter.id,
                        iconName: chatFilter.iconName,
                        unreadCount: chatFilters.first { filter in
                            filter.id == chatFilter.id
                        }?.unreadCount ?? 0
                    )
                    
                    logger.debug("Created new data struct \(newData)")
                    logger.trace("\(chatFilters.count), \(chatFilters)")
                    
                    if chatFilters.contains(where: {
                        logger.trace("\($0.id) == \(chatFilter.id)")
                        return $0.id == chatFilter.id
                    }) {
                        logger.debug("Chat filters contain a filter with id \(chatFilter.id), updating existing")
                        if let index = chatFilters.firstIndex(where: {
                            logger.trace("\($0.id) == \(chatFilter.id)")
                            return $0.id == chatFilter.id
                        }) {
                            chatFilters.update(newData, at: index)
                        }
                    } else {
                        logger.debug("Chat filters does not contain a filter with id \(chatFilter.id), creating a new one")
                        chatFilters.append(newData)
                    }
                }
                for chatFilter in chatFilters {
                    if !update.chatFilters.contains(where: { $0.id == chatFilter.id }) {
                        logger.debug("Received chat filters do not contain a filter that is already saved, removing")
                        chatFilters.remove(at: chatFilters.firstIndex { $0.id == chatFilter.id }!)
                    }
                }
            }
        }
    }

    func updateChatPosition(_ notification: NCPO) {
        let update = (notification.object as? UpdateChatPosition)!
        
        updatePosition(for: update.chatId, position: update.position)
    }
    
    func updateChatDraftMessage(_ notification: NCPO) {
        let update = (notification.object as? UpdateChatDraftMessage)!
        
        for position in update.positions {
            updatePosition(for: update.chatId, position: position)
        }
    }
    
    func updateChatLastMessage(_ notification: NCPO) {
        let update = (notification.object as? UpdateChatLastMessage)!
        
        for position in update.positions {
            updatePosition(for: update.chatId, position: position)
        }
    }
    
    func updatePosition(for chatId: Int64, position: ChatPosition) {
        if !chatPositions.contains(where: { key, value in
            key == chatId && getPosition(from: value, chatList: position.list) == position
        }) {
            withAnimation {
                if chatPositions[chatId] == nil {
                    chatPositions[chatId] = []
                }
                
                if let index = chatPositions[chatId]!.firstIndex(where: { $0.list == position.list }) {
                    chatPositions[chatId]!.remove(at: index)
                    chatPositions[chatId]!.append(position)
                } else {
                    chatPositions[chatId]!.append(position)
                }
            }
        }
        
    }

    func updateNewChat(_ notification: NCPO) {
        guard notification.object != nil else {
            return
        }
        let chat: Chat = (notification.object as? UpdateNewChat)!.chat

        _ = withAnimation {
            allChats.updateOrAppend(chat)
        }
    }
    
    func authorization(_ notification: NCPO) {
        showingLoginScreen = true
    }

    deinit {
        for subscriber in subscribers {
            subscriber.cancel()
        }
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
