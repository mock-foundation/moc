//
//  TdExtension.swift
//
//
//  Created by Егор Яковенко on 18.01.2022.
//

import Caching
import CryptoKit
import Foundation
import KeychainSwift
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
                                        applicationVersion: (
                                            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                                        ) ?? "Unknown",
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
                            case let .authorizationStateWaitEncryptionKey(info):
                                SystemUtils.post(notification: .authorizationStateWaitEncryptionKey, with: info)
                                Task {
                                    try? await self.checkDatabaseEncryptionKey(
                                        encryptionKey: TdApi.tdDatabaseEncryptionKey
                                    )
                                }
                            case .authorizationStateWaitPhoneNumber:
                                SystemUtils.post(notification: .authorizationStateWaitPhoneNumber)
                            case let .authorizationStateWaitCode(info):
                                SystemUtils.post(notification: .authorizationStateWaitCode, with: info)
                            case let .authorizationStateWaitRegistration(info):
                                SystemUtils.post(notification: .authorizationStateWaitRegistration, with: info)
                            case let .authorizationStateWaitPassword(info):
                                SystemUtils.post(notification: .authorizationStateWaitPassword, with: info)
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
                            case let .authorizationStateWaitOtherDeviceConfirmation(info):
                                SystemUtils.post(
                                    notification: .authorizationStateWaitOtherDeviceConfirmation,
                                    with: info
                                )
                            case .authorizationStateLoggingOut:
                                SystemUtils.post(notification: .authorizationStateLoggingOut)
                            case .authorizationStateClosing:
                                SystemUtils.post(notification: .authorizationStateClosing)
                            case .authorizationStateClosed:
                                SystemUtils.post(notification: .authorizationStateClosed)
                        }

                    // MARK: - Chat updates

                    case let .updateChatPosition(info):
                        SystemUtils.post(notification: .updateChatPosition, with: info)
                    case let .updateNewMessage(info):
                        SystemUtils.post(notification: .updateNewMessage, with: info)
                    case let .updateChatLastMessage(info):
                        SystemUtils.post(notification: .updateChatLastMessage, with: info)
                    case let .updateNewChat(info):
                        SystemUtils.post(notification: .updateNewChat, with: info)
                    case let .updateFile(info):
                        SystemUtils.post(notification: .updateFile, with: info)
                    case let .updateChatFilters(info):
                        try! cache.deleteAll(objects: Caching.ChatFilter.self)
                        for chatFilter in info.chatFilters {
                            cache.save(object: Caching.ChatFilter(
                                title: chatFilter.title,
                                id: chatFilter.id,
                                iconName: chatFilter.iconName
                            ))
                        }
                        SystemUtils.post(notification: .updateChatFilters, with: info)
                    default:
                        break
                }
            } catch {
                print(error)
            }
        }
    }

    static var tdDatabaseEncryptionKey: Data {
        let keychain = KeychainSwift()
        let encryptionKey = keychain.getData(tdDatabaseEncryptionKeyName)
        if encryptionKey == nil {
            let key = SymmetricKey(size: .bits256).withUnsafeBytes {
                Data(Array($0))
            }
            keychain.set(key, forKey: tdDatabaseEncryptionKeyName, withAccess: .accessibleAfterFirstUnlock)
            return key
        } else {
            return encryptionKey!
        }
    }
}
