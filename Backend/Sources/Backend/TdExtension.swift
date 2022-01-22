//
//  TdExtension.swift
//  
//
//  Created by Егор Яковенко on 18.01.2022.
//

import TDLibKit
import SystemUtils
import Logging
import KeychainSwift
import CryptoKit
import Generated
import Foundation

public extension TdApi {
    /// A list of shared instances. Why list? There could be multiple `TDLib` instances
    /// with multiple clients and multiple windows, which use their `TDLib` instance.
    /// Right now there is no multi-window and multi-account support, so just
    /// use `shared[0]`.
    static var shared: [TdApi] = []

    private static let logger = Logging.Logger(label: "TDLibUpdates")

    // swiftlint:disable cyclomatic_complexity function_body_length
    func startTdLibUpdateHandler() {
        Task {
            #if DEBUG
            try? await self.setLogVerbosityLevel(newVerbosityLevel: 5)
            #else
            try? await self.setLogVerbosityLevel(newVerbosityLevel: 0)
            #endif
        }
        self.client.run {
            do {
                let update = try self.decoder.decode(Update.self, from: $0)
                switch update {
                        // MARK: - Authorization state
                    case .updateAuthorizationState(let state):
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
                            case .authorizationStateWaitEncryptionKey(let info):
                                SystemUtils.post(notification: .authorizationStateWaitEncryptionKey, withObject: info)
                                Task {
                                    try? await self.checkDatabaseEncryptionKey(
                                        encryptionKey: TdApi.tdDatabaseEncryptionKey
                                    )
                                }
                            case .authorizationStateWaitPhoneNumber:
                                SystemUtils.post(notification: .authorizationStateWaitPhoneNumber)
                            case .authorizationStateWaitCode(let info):
                                SystemUtils.post(notification: .authorizationStateWaitCode, withObject: info)
                            case .authorizationStateWaitRegistration(let info):
                                SystemUtils.post(notification: .authorizationStateWaitRegistration, withObject: info)
                            case .authorizationStateWaitPassword(let info):
                                SystemUtils.post(notification: .authorizationStateWaitPassword, withObject: info)
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
                            case .authorizationStateWaitOtherDeviceConfirmation(let info):
                                SystemUtils.post(
                                    notification: .authorizationStateWaitOtherDeviceConfirmation,
                                    withObject: info
                                )
                            case .authorizationStateLoggingOut:
                                SystemUtils.post(notification: .authorizationStateLoggingOut)
                            case .authorizationStateClosing:
                                SystemUtils.post(notification: .authorizationStateClosing)
                            case .authorizationStateClosed:
                                SystemUtils.post(notification: .authorizationStateClosed)
                        }
                        // MARK: - Chat updates
                    case .updateChatPosition(let info):
                        SystemUtils.post(notification: .updateChatPosition, withObject: info)
                    case .updateNewMessage(let info):
                        SystemUtils.post(notification: .updateNewMessage, withObject: info)
                    case .updateChatLastMessage(let info):
                        SystemUtils.post(notification: .updateChatLastMessage, withObject: info)
                    case .updateNewChat(let info):
                        SystemUtils.post(notification: .updateNewChat, withObject: info)
                    case .updateFile(let info):
                        SystemUtils.post(notification: .updateFile, withObject: info)
                    default:
                        #if DEBUG
                        TdApi.logger.warning("Unhandled TDLib update \(update)")
                        #endif
                }
            } catch {
                #if DEBUG
                TdApi.logger.error("Error in TDLib update handler \(error.localizedDescription)")
                #endif
            }
        }
    }

    static var tdDatabaseEncryptionKey: Data {
        let keychain = KeychainSwift()
        let encryptionKey = keychain.getData("tdDatabaseEncryptionKey")
        if encryptionKey == nil {
            let key = SymmetricKey(size: .bits256).withUnsafeBytes {
                return Data(Array($0))
            }
            keychain.set(key, forKey: "tdDatabaseEncryptionKey", withAccess: .accessibleAfterFirstUnlock)
            return key
        } else {
            return encryptionKey!
        }
    }
}
