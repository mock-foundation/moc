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
import Caching
import Network

class MainViewModel: ObservableObject {
    @Injected var service: MainService
    
    @Published var connectionStateTitle = ""
    @Published var isConnectionStateShown = true
    @Published var isConnected = true
    private var loadingAnimationTimer: Timer?
    private var loadingAnimationState = 3
        
    // just a helper function to filter out a set of chat positions
    private func getPosition(from positions: [ChatPosition], chatList: TDLibKit.ChatList) -> ChatPosition? {
        return positions.first { position in
            position.list == chatList
        }
    }
    
    private func chats(from chatList: TDLibKit.ChatList) -> [Chat] {
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
        switch openChatList {
            case .main:
                return chats(from: .chatListMain)
            case .archive:
                return chats(from: .chatListArchive)
            case .filter(let id):
                return chats(from: .chatListFilter(.init(chatFilterId: id)))
        }
    }
    
    @Published var unreadCounters: [Caching.UnreadCounter] = []
    @Published var chatFilters: [TDLibKit.ChatFilterInfo] = []
    
    var mainUnreadCounter: Int {
        unreadCounters
            .first { $0.chatList == .main }?.chats ?? 0
    }
    
    var folders: [ChatFolder] {
        return chatFilters.map { filter in
            return ChatFolder(
                title: filter.title,
                id: filter.id,
                iconName: filter.iconName,
                unreadCounter: unreadCounters
                    .first { $0.chatList == .filter(filter.id) }?
                    .chats ?? 0)
        }
    }
    
    @Published var allChats: OrderedSet<Chat> = []
    @Published var chatPositions: [Int64: [ChatPosition]] = [:]
    
    @Published var openChatList: Caching.ChatList = .main {
        didSet {
            logger.trace("openChatList: \(openChatList)")
            if openChatList != .archive {
                openChatListBuffer = openChatList
            }
            Task {
                switch openChatList {
                    case .main:
                        try await TdApi.shared[0].loadChats(
                            chatList: .chatListMain,
                            limit: 30)
                    case .archive:
                        try await TdApi.shared[0].loadChats(
                            chatList: .chatListArchive,
                            limit: 30)
                    case .filter(let id):
                        try await TdApi.shared[0].loadChats(
                            chatList: .chatListFilter(.init(chatFilterId: id)),
                            limit: 30)
                }
            }
        }
    }
    
    private var openChatListBuffer: Caching.ChatList = .main {
        didSet {
            logger.trace("openChatListBuffer: \(openChatListBuffer)")
        }
    }
    
    @Published var isArchiveOpen = false {
        didSet {
            if isArchiveOpen {
                openChatList = .archive
            } else {
                openChatList = openChatListBuffer
            }
        }
    }

    @Published var showingLoginScreen = false

    private var subscribers: [AnyCancellable] = []
    private var logger = Logs.Logger(category: "MainViewModel", label: "UI")
    private var nwPathMonitorQueue = DispatchQueue(label: "NWPathMonitorQueue", qos: .utility)

    init() {
        if let filters = try? service.getFilters() {
            logger.debug("Filling chat filter with cached ones: \(filters)")
            chatFilters = filters.map { filter in
                ChatFilterInfo(iconName: filter.iconName, id: filter.id, title: filter.title)
            }
            logger.trace("\(filters.count), \(chatFilters.count)")
        } else {
            logger.debug("There was an issue retrieving cached chat filters (maybe empty?), using empty OrderedSet")
            chatFilters = []
        }
        addSubscriber(for: .updateChatPosition, action: updateChatPosition(_:))
        addSubscriber(for: .authorizationStateWaitPhoneNumber, action: authorization(_:))
        addSubscriber(for: .updateNewChat, action: updateNewChat(_:))
        addSubscriber(for: .updateChatFilters, action: updateChatFilters(_:))
        addSubscriber(for: .updateUnreadChatCount, action: updateUnreadChatCount(_:))
        addSubscriber(for: .updateChatLastMessage, action: updateChatLastMessage(_:))
        addSubscriber(for: .updateChatDraftMessage, action: updateChatDraftMessage(_:))
        addSubscriber(for: .updateConnectionState, action: updateConnectionState(_:))
        NWPathMonitor()
            .publisher(queue: nwPathMonitorQueue)
            .sink { value in
                Task {
                    switch value {
                        case .satisfied:
                            try await TdApi.shared[0].setNetworkType(type: .networkTypeOther)
                        case .unsatisfied:
                            try await TdApi.shared[0].setNetworkType(type: .networkTypeNone)
                        case .requiresConnection:
                            try await TdApi.shared[0].setNetworkType(type: .networkTypeNone)
                        @unknown default:
                            try await TdApi.shared[0].setNetworkType(type: .networkTypeNone)
                    }
                }
            }
            .store(in: &subscribers)
            
    }
    
    func addSubscriber(for notification: NSNotification.Name, action: @escaping ((NCPO) -> Void)) {
        SystemUtils.ncPublisher(for: notification)
            .receive(on: RunLoop.main)
            .sink(receiveValue: action)
            .store(in: &subscribers)
    }
    
    func updateConnectionState(_ notification: NCPO) {
        logger.debug(notification.name.rawValue)
        let update = notification.object as! UpdateConnectionState
        loadingAnimationTimer?.invalidate()
        loadingAnimationTimer = nil
        loadingAnimationState = 3
        
        DispatchQueue.main.async { [self] in
            var needStartTimer = true

            switch update.state {
                case .connectionStateWaitingForNetwork:
                    connectionStateTitle = "Waiting for network..."
                    isConnectionStateShown = true
                    isConnected = false
                case .connectionStateConnectingToProxy:
                    connectionStateTitle = "Connecting to proxy..."
                    isConnectionStateShown = true
                    isConnected = false
                case .connectionStateConnecting:
                    connectionStateTitle = "Connecting..."
                    isConnectionStateShown = true
                    isConnected = false
                case .connectionStateUpdating:
                    connectionStateTitle = "Updating..."
                    isConnectionStateShown = true
                    isConnected = false
                case .connectionStateReady:
                    loadingAnimationTimer?.invalidate()
                    loadingAnimationTimer = nil
                    needStartTimer = false

                    connectionStateTitle = "Connected!"
                    isConnected = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.isConnectionStateShown = false
                    }
            }
            
            if needStartTimer {
                loadingAnimationTimer = Timer.scheduledTimer(
                    withTimeInterval: 0.5,
                    repeats: true
                ) { [weak self] timer in
                    guard let strongSelf = self else { return }
                    guard self?.isConnected == false else {
                        timer.invalidate()
                        return
                    }
                    
                    if strongSelf.loadingAnimationState != 3 {
                        strongSelf.loadingAnimationState += 1
                        DispatchQueue.main.async {
                            var buffer = strongSelf.connectionStateTitle
                            buffer.append(".")
                            strongSelf.connectionStateTitle = buffer
                        }
                    } else {
                        strongSelf.loadingAnimationState = 0
                        DispatchQueue.main.async {
                            strongSelf.connectionStateTitle = String(
                                strongSelf.connectionStateTitle.prefix(strongSelf.connectionStateTitle.count - 3))
                        }
                    }
                }
            }
        }
    }
    
    func updateUnreadChatCount(_ notification: NCPO) {
        logger.debug("UpdateUnreadChatCount")
        let update = notification.object as! UpdateUnreadChatCount
        
        var shouldBeAdded = true
        let chatList = Caching.ChatList.from(tdChatList: update.chatList)
        let unreads = try! service.getUnreadCounters()
        
        logger.debug("Going through unreads")
        for unread in unreads where chatList == unread.chatList {
            logger.debug("Found a one to be updated")
            let newValue = UnreadCounter(
                chats: update.unreadCount,
                messages: unread.messages,
                chatList: unread.chatList
            )
            if let index = unreadCounters.firstIndex(where: { $0.chatList == chatList }) {
                unreadCounters.remove(at: index)
            }
            unreadCounters.append(newValue)
            shouldBeAdded = false
        }
        
        if shouldBeAdded {
            logger.debug("Adding a new one")
            unreadCounters.append(UnreadCounter(
                chats: update.unreadCount,
                messages: 0,
                chatList: chatList
            ))
        }
    }
    
    func updateChatFilters(_ notification: NCPO) {
        let update = notification.object as! UpdateChatFilters
        logger.debug("Chat filter update")
        
        withAnimation {
            chatFilters = update.chatFilters
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
        logger.debug("Got authorization state update")
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
