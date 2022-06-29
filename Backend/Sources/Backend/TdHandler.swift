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
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

public extension TdApi {
    /// A list of shared instances. Why list? There could be multiple `TDLib` instances
    /// with multiple clients and multiple windows, which use their `TDLib` instance.
    /// Right now there is no multi-window and multi-account support, so just
    /// use `shared[0]`.
    static var shared: [TdApi] = []

    private static let logger = Logs.Logger(category: "TDLib", label: "Updates")

    // swiftlint:disable cyclomatic_complexity function_body_length
    func startTdLibUpdateHandler() {
        TdApi.logger.debug("Starting handler")
        
        client.run {
            let cache = CacheService.shared
            
            Task {
                #if DEBUG
                try? await self.setLogVerbosityLevel(newVerbosityLevel: 2)
                #else
                try? await self.setLogVerbosityLevel(newVerbosityLevel: 0)
                #endif
            }
            do {
                let update = try self.decoder.decode(Update.self, from: $0)
//                TdApi.logger.debug("\(update)")
                
                switch update {
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
                                    var dir = ""
                                    if #available(macOS 13, iOS 16, *) {
                                        url.append(path: "td")
                                        dir = url.path()
                                    } else {
                                        url.appendPathComponent("td")
                                        dir = url.path
                                    }
                                    _ = try await self.setTdlibParameters(parameters: TdlibParameters(
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
                                    _ = try await self.loadChats(chatList: .chatListMain, limit: 15)
                                    _ = try await self.loadChats(chatList: .chatListArchive, limit: 15)
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
                                TdApi.shared.insert(TdApi(
                                    client: TdClientImpl(completionQueue: .global())
                                ), at: 0)
                                TdApi.shared[0].startTdLibUpdateHandler()
                        }
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
                    case let .updateConnectionState(info):
                        SystemUtils.post(notification: .updateConnectionState, with: info)
                    case let .updateFileGenerationStart(info):
                        switch info.conversion {
                            case "copy":
                                Task {
                                    do {
                                        TdApi.logger.debug(
                                            """
                                            Starting conversion with id \(info.generationId.rawValue) \
                                            by running command \(info.conversion) \
                                            from \(info.originalPath) \
                                            to \(info.destinationPath)
                                            """
                                            )
                                        if FileManager.default.fileExists(atPath: info.destinationPath) {
                                            try FileManager.default.removeItem(atPath: info.destinationPath)
                                        }
                                        if #available(macOS 13, iOS 16, *) {
                                            try FileManager.default.copyItem(
                                                at: URL(filePath: info.originalPath),
                                                to: URL(filePath: info.destinationPath))
                                        } else {
                                            try FileManager.default.copyItem(
                                                at: URL(fileURLWithPath: info.originalPath),
                                                to: URL(fileURLWithPath: info.destinationPath))
                                        }
                                        TdApi.logger.debug("Conversion with id \(info.generationId.rawValue) is done")
                                        _ = try await TdApi.shared[0].finishFileGeneration(
                                            error: nil,
                                            generationId: info.generationId)
                                    } catch {
                                        _ = try await TdApi.shared[0].finishFileGeneration(
                                            error: Error(code: 400, message: error.localizedDescription),
                                            generationId: info.generationId)
                                    }
                                }
                            case "video_thumbnail":
                                Task {
                                    do {
                                        let thumbnail = URL(fileURLWithPath: info.originalPath).platformThumbnail
                                        
                                        #if os(macOS)
                                        if let imgRep = thumbnail.representations[0] as? NSBitmapImageRep {
                                            if let data = imgRep.representation(using: .png, properties: [:]) {
                                                try data.write(to: URL(fileURLWithPath: info.destinationPath), options: .atomic)
                                            }
                                        }
                                        #elseif os(iOS)
                                        if let data = thumbnail.pngData() {
                                            try? data.write(to: URL(fileURLWithPath: info.destinationPath), options: .atomic)
                                        }
                                        #endif
                                        _ = try await TdApi.shared[0].finishFileGeneration(
                                            error: nil,
                                            generationId: info.generationId)
                                        TdApi.logger.debug("File generation with ID \(info.generationId) is done")
                                    } catch {
                                        TdApi.logger.debug("File generation with ID \(info.generationId) failed")
                                        _ = try await TdApi.shared[0].finishFileGeneration(
                                            error: Error(code: 400, message: error.localizedDescription),
                                            generationId: info.generationId)
                                    }
                                }
                            default:
                                break
                        }
                    case .updateFileGenerationStop(_):
                        break
                    default:
                        break
                }
            } catch {
                let tdError = error as! TDLibKit.Error
                TdApi.logger.error("Code: \(tdError.code), message: \(tdError.message)")
            }
        }
    }
}
