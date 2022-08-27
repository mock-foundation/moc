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
    static var shared: TdApi = TdApi(client: TdClientImpl(completionQueue: .global()))

    private static let logger = Logs.Logger(category: "TDLib", label: "Updates")

    // swiftlint:disable function_body_length cyclomatic_complexity
    func startTdLibUpdateHandler() {
        TdApi.logger.debug("Starting handler")
        
        Task {
            #if DEBUG
            try await self.setLogVerbosityLevel(newVerbosityLevel: 2)
            #else
            try await self.setLogVerbosityLevel(newVerbosityLevel: 0)
            #endif
        }
        
        client.run {
            let cache = CacheService.shared
            
            do {
                let update = try TdApi.decoder.decode(Update.self, from: $0)
                
                switch update {
                    case let .authorizationState(state):
                        switch state.authorizationState {
                            case .waitTdlibParameters:
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
                                        deviceModel: await SystemUtils.getDeviceModel(),
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
                            case .waitEncryptionKey:
                                Task {
                                    try? await self.checkDatabaseEncryptionKey(
                                        encryptionKey: Data()
                                    )
                                }
                            case .ready:
                                Task {
                                    _ = try await self.loadChats(chatList: .main, limit: 15)
                                    _ = try await self.loadChats(chatList: .archive, limit: 15)
                                }
                            case .closed:
                                TdApi.shared = TdApi(
                                    client: TdClientImpl(completionQueue: .global())
                                )
                                TdApi.shared.startTdLibUpdateHandler()
                            default: break
                        }
                    case let .chatFilters(update):
                        try cache.deleteAll(records: Caching.ChatFolder.self)
                        for (index, filter) in update.chatFilters.enumerated() {
                            try cache.save(record: Caching.ChatFolder(
                                title: filter.title,
                                id: filter.id,
                                iconName: filter.iconName,
                                order: index))
                        }
                    case let .unreadChatCount(update):
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
                    case let .unreadMessageCount(update):
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
                    case let .fileGenerationStart(info):
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
                                        _ = try await TdApi.shared.finishFileGeneration(
                                            error: nil,
                                            generationId: info.generationId)
                                    } catch {
                                        _ = try await TdApi.shared.finishFileGeneration(
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
                                                try data.write(
                                                    to: URL(fileURLWithPath: info.destinationPath),
                                                    options: .atomic)
                                            }
                                        }
                                        #elseif os(iOS)
                                        if let data = thumbnail.pngData() {
                                            try? data.write(
                                                to: URL(fileURLWithPath: info.destinationPath),
                                                options: .atomic)
                                        }
                                        #endif
                                        _ = try await TdApi.shared.finishFileGeneration(
                                            error: nil,
                                            generationId: info.generationId)
                                        TdApi.logger.debug("File generation with ID \(info.generationId) is done")
                                    } catch {
                                        TdApi.logger.debug("File generation with ID \(info.generationId) failed")
                                        _ = try await TdApi.shared.finishFileGeneration(
                                            error: Error(code: 400, message: error.localizedDescription),
                                            generationId: info.generationId)
                                    }
                                }
                            default: break
                        }
                    default: break
                }
            } catch {
                let tdError = error as? TDLibKit.Error
                guard let tdError else { return }
                TdApi.logger.error("Code: \(tdError.code), message: \(tdError.message)")
            }
        }
    }
}
