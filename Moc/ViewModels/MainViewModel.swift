//
//  MainViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 01.01.2022.
//

import Resolver
import SwiftUI

class MainViewModel: ObservableObject {
    // MARK: - Chat lists

    @Published var mainChatList: [Chat] = []
    @Published var archiveChatList: [Chat] = []
    @Published var folderChatLists: [Int: [Chat]] = [:]

    /// For chats that have not received updateChatPosition update, and are waiting for distribution.
    var unorderedChatList: [Chat] = []

//        .onReceive(SystemUtils.ncPublisher(for: .updateChatPosition)) { notification in
//            logger.info("Update chat position")
//            let update = (notification.object as? UpdateChatPosition)!
//            let position = update.position
//            let chatId = update.chatId
//
//            if mainViewModel.unorderedChatList.contains(where: { $0.id == chatId }) {
//                switch position.list {
//                    case .chatListMain:
//                        let chats = mainViewModel.unorderedChatList.filter { chat in
//                            chat.id == chatId
//                        }
//                        for chat in chats {
//                            mainViewModel.mainChatList.append(chat)
//                        }
//                        mainViewModel.unorderedChatList = mainViewModel.unorderedChatList.filter {
//                            return $0.id != chatId
//                        }
//                        sortMainChatList()
//                    case .chatListArchive:
//                        let chats = mainViewModel.unorderedChatList.filter { chat in
//                            chat.id == chatId
//                        }
//                        for chat in chats {
//                            mainViewModel.archiveChatList.append(chat)
//                        }
//                        mainViewModel.unorderedChatList = mainViewModel.unorderedChatList.filter {
//                            return $0.id != chatId
//                        }
//                        sortArchiveChatList()
//                    default:
//                        break
//                }
//            }
//        }
    //        .onReceive(SystemUtils.ncPublisher(for: .updateNewChat)) { data in
    //            logger.info("Received new chat update")
    //            guard data.object != nil else {
    //                return
    //            }
    //            let chat = (data.object as? UpdateNewChat)!.chat
    //
    //            let hasChat = mainViewModel.unorderedChatList.contains(where: {
    //                $0.id == chat.id
    //            })
    //
    //            if !hasChat {
    //                mainViewModel.unorderedChatList.append(chat)
    //            }
    //
    //            logger.info("\(chat)")
    //
    //            sortMainChatList()
    //        }
    //        .onReceive(SystemUtils.ncPublisher(for: .authorizationStateWaitPhoneNumber)) { _ in
    //            showingLoginScreen = true
    //        }

    //    private func sortMainChatList() {
    //        mainViewModel.mainChatList = mainViewModel.mainChatList.sorted {
    //            if !$0.positions.isEmpty, !$1.positions.isEmpty {
    //                return $0.positions[0].order.rawValue > $1.positions[0].order.rawValue
    //            } else {
    //                return true
    //            }
    //            //            if $0.lastMessage?.date ?? 1 > $1.lastMessage?.date ?? 0 {
    //            //                return true
    //            //            } else {
    //            //                return false
    //            //            }
    //        }
    //    }
    //
    //    private func sortArchiveChatList() {
    //        mainViewModel.archiveChatList = mainViewModel.archiveChatList.sorted {
    //            if !$0.positions.isEmpty, !$1.positions.isEmpty {
    //                return $0.positions[0].order.rawValue > $1.positions[0].order.rawValue
    //            } else {
    //                return true
    //            }
    //        }
    //    }
}
