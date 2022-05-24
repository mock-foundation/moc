//
//  MainViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 01.01.2022.
//

import Resolver
import SwiftUI
import Utils
import Combine
import TDLibKit
import Logging

private enum Event {
    case updateChatPosition
    case authorization
    case updateNewChat
}

class MainViewModel: ObservableObject {
    // MARK: - Chat lists

    @Published var mainChatList: [Chat] = []
    @Published var archiveChatList: [Chat] = []
    @Published var folderChatLists: [Int: [Chat]] = [:]

    @Published var showingLoginScreen = false

    /// For chats that have not received updateChatPosition update, and are waiting for distribution.
    var unorderedChatList: [Chat] = []

    private var publishers: [Event: NotificationCenter.Publisher] = [:]
    private var subscribers: [Event: AnyCancellable] = [:]

    private var logger = Logging.Logger(label: "UI", category: "MainViewModel")

    init() {
        publishers[.updateChatPosition] = SystemUtils.ncPublisher(for: .updateChatPosition)
        publishers[.authorization] = SystemUtils.ncPublisher(for: .authorizationStateWaitPhoneNumber)
        publishers[.updateNewChat] = SystemUtils.ncPublisher(for: .updateNewChat)
    }

    func registerSubscriptions() {
        subscribers[.updateChatPosition] = publishers[.updateChatPosition]?.sink(
            receiveValue: updateChatPosition(notification:)
        )
        subscribers[.authorization] = publishers[.authorization]?.sink(receiveValue: authorization(notification:))
        subscribers[.updateNewChat] = publishers[.updateNewChat]?.sink(receiveValue: updateNewChat(notification:))
    }

    func updateChatPosition(notification: NotificationCenter.Publisher.Output) {
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

    func authorization(notification: NotificationCenter.Publisher.Output) {
        showingLoginScreen = true
    }

    func updateNewChat(notification: NotificationCenter.Publisher.Output) {
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
        mainChatList = mainChatList.sorted {
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
        archiveChatList = archiveChatList.sorted {
            if !$0.positions.isEmpty, !$1.positions.isEmpty {
                return $0.positions[0].order.rawValue > $1.positions[0].order.rawValue
            } else {
                return true
            }
        }
    }
}
