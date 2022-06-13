//
//  TdExtension.swift
//
//
//  Created by Егор Яковенко on 18.01.2022.
//

import Caching
import Foundation
import Logs
import TDLibKit
import Utilities

public extension TdApi {
    /// A list of shared instances. Why list? There could be multiple `TDLib` instances
    /// with multiple clients and multiple windows, which use their `TDLib` instance.
    /// Right now there is no multi-window and multi-account support, so just
    /// use `shared[0]`.
    static var shared: [TdApi] = []

    private static let logger = Logs.Logger(label: "TDLib", category: "Updates")

    // swiftlint:disable cyclomatic_complexity function_body_length
    func startTdLibUpdateHandler() {
        TdApi.logger.debug("Starting handler")
        Task {
            #if DEBUG
            try? await self.setLogVerbosityLevel(newVerbosityLevel: 2)
            #else
            try? await self.setLogVerbosityLevel(newVerbosityLevel: 0)
            #endif
        }
        client.run {
            let cache = CacheService.shared
            do {
                let update = try self.decoder.decode(Update.self, from: $0)
            
                switch update {
                    // MARK: - Authorization state
                    case let .updateAuthorizationState(state):
                        switch state.authorizationState {
                            case .authorizationStateWaitTdlibParameters:
                                SystemUtils.post(notification: .authorizationStateWaitTdlibParameters)
                                Task {
                                    var url = try FileManager.default.url(
                                        for: .applicationSupportDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: true)
                                    if #available(macOS 13, iOS 16, *) {
                                        url.append(path: "td")
                                    } else {
                                        url.appendPathComponent("td")
                                    }
                                    var dir = ""
                                    if #available(macOS 13, iOS 16, *) {
                                        dir = url.path()
                                    } else {
                                        dir = url.path
                                    }
                                    try await self.setTdlibParameters(parameters: TdlibParameters(
                                        apiHash: Secret.apiHash,
                                        apiId: Secret.apiId,
                                        applicationVersion: SystemUtils.info(key: "CFBundleShortVersionString"),
                                        databaseDirectory: dir,
                                        deviceModel: SystemUtils.deviceModel,
                                        enableStorageOptimizer: true,
                                        filesDirectory: dir,
                                        ignoreFileNames: false,
                                        systemLanguageCode: "en-US",
                                        systemVersion: SystemUtils.osVersionString,
                                        useChatInfoDatabase: true,
                                        useFileDatabase: true,
                                        useMessageDatabase: true,
                                        useSecretChats: false,
                                        useTestDc: false
                                    ))
                                }
                            case let .authorizationStateWaitEncryptionKey(update):
                                SystemUtils.post(notification: .authorizationStateWaitEncryptionKey, with: update)
                                Task {
                                    try? await self.checkDatabaseEncryptionKey(
                                        encryptionKey: Data()
                                    )
                                }
                            case .authorizationStateWaitPhoneNumber:
                                SystemUtils.post(notification: .authorizationStateWaitPhoneNumber)
                            case let .authorizationStateWaitCode(update):
                                SystemUtils.post(notification: .authorizationStateWaitCode, with: update)
                            case let .authorizationStateWaitRegistration(update):
                                SystemUtils.post(notification: .authorizationStateWaitRegistration, with: update)
                            case let .authorizationStateWaitPassword(update):
                                SystemUtils.post(notification: .authorizationStateWaitPassword, with: update)
                            case .authorizationStateReady:
                                Task {
                                    do {
                                        _ = try await self.loadChats(chatList: .chatListMain, limit: 15)
                                        _ = try await self.loadChats(chatList: .chatListArchive, limit: 15)
                                    } catch {
                                        TdApi.logger.error("Failed to load chats")
                                    }
                                }
                                SystemUtils.post(notification: .authorizationStateReady)
                            case let .authorizationStateWaitOtherDeviceConfirmation(update):
                                SystemUtils.post(
                                    notification: .authorizationStateWaitOtherDeviceConfirmation,
                                    with: update
                                )
                            case .authorizationStateLoggingOut:
                                SystemUtils.post(notification: .authorizationStateLoggingOut)
                            case .authorizationStateClosing:
                                SystemUtils.post(notification: .authorizationStateClosing)
                            case .authorizationStateClosed:
                                SystemUtils.post(notification: .authorizationStateClosed)
                        }

                    // MARK: - Chat updates

                    case let .updateChatPosition(update):
                        SystemUtils.post(notification: .updateChatPosition, with: update)
                    case let .updateChatLastMessage(update):
                        SystemUtils.post(notification: .updateChatLastMessage, with: update)
                    case let .updateChatDraftMessage(update):
                        SystemUtils.post(notification: .updateChatDraftMessage, with: update)
                    case let .updateNewMessage(update):
                        SystemUtils.post(notification: .updateNewMessage, with: update)
                    case let .updateNewChat(update):
                        SystemUtils.post(notification: .updateNewChat, with: update)
                    case let .updateFile(update):
                        SystemUtils.post(notification: .updateFile, with: update)
                    case let .updateChatFilters(update):
                        SystemUtils.post(notification: .updateChatFilters, with: update)

                        try cache.deleteAll(records: Caching.ChatFilter.self)
                        for (index, filter) in update.chatFilters.enumerated() {
                            try cache.save(record: Caching.ChatFilter(
                                title: filter.title,
                                id: filter.id,
                                iconName: filter.iconName,
                                order: index))
                        }
                    case let .updateUnreadChatCount(update):
                        SystemUtils.post(notification: .updateUnreadChatCount, with: update)

                        var shouldBeAdded = true
                        let chatList = Caching.ChatList.from(tdChatList: update.chatList)
                        let records = try cache.getRecords(as: UnreadCounter.self)
                        
                        for record in records where chatList == record.chatList {
                            try cache.modify(record: UnreadCounter.self, at: chatList) { record in
                                record.chats = update.unreadCount
                            }
                            shouldBeAdded = false
                        }
                        
                        if shouldBeAdded {
                            try cache.save(record: UnreadCounter(
                                chats: update.unreadCount,
                                messages: 0,
                                chatList: chatList
                            ))
                        }
                    case let .updateUnreadMessageCount(update):
                        SystemUtils.post(notification: .updateUnreadMessageCount, with: update)
                        
                        var shouldBeAdded = true
                        let chatList = Caching.ChatList.from(tdChatList: update.chatList)
                        let records = try cache.getRecords(as: UnreadCounter.self)
                        
                        for record in records where chatList == record.chatList {
                            try cache.modify(record: UnreadCounter.self, at: chatList) { record in
                                record.messages = update.unreadCount
                            }
                            shouldBeAdded = false
                        }
                        
                        if shouldBeAdded {
                            try cache.save(record: UnreadCounter(
                                chats: 0,
                                messages: update.unreadCount,
                                chatList: chatList
                            ))
                        }
                    default:
                        break
                }
            } catch {
                TdApi.logger.error(error.localizedDescription)
            }
        }
    }
}
