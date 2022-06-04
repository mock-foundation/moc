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
                                    try? await self.setTdlibParameters(parameters: TdlibParameters(
                                        apiHash: Secret.apiHash,
                                        apiId: Secret.apiId,
                                        applicationVersion: SystemUtils.info(key: "CFBundleShortVersionString"),
                                        databaseDirectory: "td",
                                        deviceModel: SystemUtils.macModel,
                                        enableStorageOptimizer: true,
                                        filesDirectory: "td",
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
                        let objects = try cache.getRecords(as: Caching.ChatFilter.self)
                        TdApi.logger.debug("Going over received chat filters")
                        for (index, chatFilter) in update.chatFilters.enumerated() {
                            if objects.contains(where: { $0.id == chatFilter.id }) {
                                TdApi.logger.debug("Updating filter with id \(chatFilter.id) in database")
                                try cache.modify(record: Caching.ChatFilter.self, at: chatFilter.id) {
                                    $0.title = chatFilter.title
                                    $0.id = chatFilter.id
                                    $0.iconName = chatFilter.iconName
                                    $0.order = index
                                }
                            } else {
                                TdApi.logger.debug("Creating a new one with id \(chatFilter.id)")
                                try cache.save(record: Caching.ChatFilter(
                                    title: chatFilter.title,
                                    id: chatFilter.id,
                                    iconName: chatFilter.iconName,
                                    order: index
                                ))
                            }
                        }
                        TdApi.logger.debug("Going over filters in database")
                        for object in objects {
                            if !update.chatFilters.contains(where: { $0.id == object.id }) {
                                TdApi.logger.debug("Update does not contain filter with id \(object.id), removing from database")
                                try cache.delete(record: object)
                            }
                        }
                        SystemUtils.post(notification: .updateChatFilters, with: update)
                    case let .updateUnreadChatCount(update):
                        switch update.chatList {
                            case let .chatListFilter(filter):
                                do {
                                    try cache.modify(record: Caching.ChatFilter.self, at: filter.chatFilterId) {
                                        $0.unreadCount = update.unreadCount
                                    }
                                } catch {
                                    print(error)
                                }
                            default: break
                        }
                        SystemUtils.post(notification: .updateUnreadChatCount, with: update)
                    default:
                        break
                }
            } catch {
                print(error)
            }
        }
    }
}
