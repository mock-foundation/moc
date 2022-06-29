//
//  TdChatService.swift
//
//
//  Created by Егор Яковенко on 18.01.2022.
//

import Combine
import Foundation
import AVKit
import SwiftUI
import Utilities
import TDLibKit
import Logs
import UniformTypeIdentifiers

public class TdChatService: ChatService {
    public func setAction(_ action: ChatAction) async throws {
        _ = try await tdApi.sendChatAction(action: action, chatId: chatId, messageThreadId: nil)
    }
    
    public func sendMessage(_ message: String) async throws {
        _ = try await tdApi.sendMessage(
            chatId: chatId!,
            inputMessageContent: .inputMessageText(
                InputMessageText(
                    clearDraft: true,
                    disableWebPagePreview: false,
                    text: FormattedText(entities: [], text: message)
                )),
            messageThreadId: nil,
            options: nil,
            replyMarkup: nil,
            replyToMessageId: nil
        )
    }
    
    public func sendMedia(_ url: URL, caption: String) async throws {
//        let fileExtension = url.pathExtension
//        let uti = UTType(filenameExtension: fileExtension)
        
//        if uti!.conforms(to: .image) {
        var path = url.filePath ?? ""
        
        logger.info("Sending media with path \(path)")
        #if os(macOS)
        guard let image = NSImage(contentsOf: url) else {
            logger.error("Failed to create an NSImage instance for supplied path \(path)")
            return
        }
        #elseif os(iOS)
        guard let image = UIImage(contentsOfFile: path) else {
            logger.error("Failed to create an UIImage instance for supplied path \(path)")
            return
        }
        #endif
        
        let inputGenerated = InputFile.inputFileGenerated(InputFileGenerated(
            conversion: "copy",
            expectedSize: 0,
            originalPath: path))
        
        _ = try await tdApi.sendMessage(
            chatId: chatId!,
            inputMessageContent: .inputMessagePhoto(InputMessagePhoto(
                addedStickerFileIds: [],
                caption: FormattedText(entities: [], text: caption),
                height: Int(image.size.height),
                photo: inputGenerated,
                thumbnail: InputThumbnail(
                    height: Int(image.size.height),
                    thumbnail: inputGenerated,
                    width: Int(image.size.width)),
                ttl: 0,
                width: Int(image.size.width))),
            messageThreadId: nil,
            options: nil,
            replyMarkup: nil,
            replyToMessageId: nil
        )
        logger.debug("Done")
//        }
    }
    
    public func sendAlbum(_ urls: [URL], caption: String) async throws {
        let messageContents: [InputMessageContent] = await urls.asyncMap { url in
            var path = url.absoluteString
            path = String(path.suffix(from: .init(utf16Offset: 7, in: path))).removingPercentEncoding ?? ""
            
            let uti = UTType(url)
            logger.debug("UTType: \(uti)")
            
            let inputGenerated: InputFile = .inputFileGenerated(InputFileGenerated(
                conversion: "copy",
                expectedSize: 0,
                originalPath: path))
            
            let messageDocument: InputMessageContent = .inputMessageDocument(InputMessageDocument(
                caption: FormattedText(entities: [], text: caption),
                disableContentTypeDetection: false,
                document: inputGenerated,
                thumbnail: InputThumbnail(
                    height: 0,
                    thumbnail: inputGenerated,
                    width: 0)))
                        
            if uti!.conforms(to: .image) {
                logger.info("Sending media with path \(path)")
                
                #if os(macOS)
                let image = NSImage(contentsOf: url)!
                #elseif os(iOS)
                let image = UIImage(contentsOfFile: path)!
                #endif
                
                return .inputMessagePhoto(InputMessagePhoto(
                        addedStickerFileIds: [],
                        caption: FormattedText(entities: [], text: caption),
                        height: Int(image.size.height),
                        photo: inputGenerated,
                        thumbnail: InputThumbnail(
                            height: Int(image.size.height),
                            thumbnail: inputGenerated,
                            width: Int(image.size.width)),
                        ttl: 0,
                        width: Int(image.size.width)))
            } else if uti!.conforms(toAtLeastOneOf: [
                .video,
                .mpeg4Movie,
                .mpeg2Video,
                .appleProtectedMPEG4Video,
                .quickTimeMovie]
            ) {
                var size: CGSize? = nil
                let asset = AVURLAsset(url: url)
                if #available(macOS 13, iOS 16, *) {
                    guard let track = try? await asset.loadTracks(withMediaType: .video).first else {
                        return messageDocument
                    }
                    let tempSize = track.naturalSize.applying(track.preferredTransform)
                    size = CGSize(width: abs(tempSize.width), height: abs(tempSize.height))
                } else {
                    guard let track = asset.tracks(withMediaType: .video).first else {
                        return messageDocument
                    }
                    let tempSize = track.naturalSize.applying(track.preferredTransform)
                    size = CGSize(width: abs(tempSize.width), height: abs(tempSize.height))
                }
                
                return .inputMessageVideo(InputMessageVideo(
                    addedStickerFileIds: [],
                    caption: FormattedText(entities: [], text: caption),
                    duration: Int(CMTimeGetSeconds(asset.duration)),
                    height: Int(size!.height),
                    supportsStreaming: true,
                    thumbnail: InputThumbnail(
                        height: Int(size!.height),
                        thumbnail: .inputFileGenerated(InputFileGenerated(
                            conversion: "video_thumbnail",
                            expectedSize: 0,
                            originalPath: path)),
                        width: Int(size!.width)),
                    ttl: 0,
                    video: inputGenerated,
                    width: Int(size!.width)))
            }
            return messageDocument
        }
        
        _ = try await tdApi.sendMessageAlbum(
            chatId: chatId!,
            inputMessageContents: messageContents,
            messageThreadId: nil,
            onlyPreview: nil,
            options: nil,
            replyToMessageId: nil)
    }
    
    private var logger = Logs.Logger(category: "Services", label: "TdChatDataSource")
    public var tdApi: TdApi = .shared[0]

    public func set(protected _: Bool) async throws {
        logger.error("set(protected:) not implemented")
    }

    public func getUser(by id: Int64) async throws -> User {
        try await self.tdApi.getUser(userId: id)
    }

    public func getChat(by id: Int64) async throws -> Chat {
        try await self.tdApi.getChat(chatId: id)
    }

    public func getMessageSenderName(_ sender: MessageSender) throws -> String {
        switch sender {
        case let .messageSenderUser(messageSenderUser):
            var str = ""
            try tdApi.getUser(userId: messageSenderUser.userId) { result in
                switch result {
                case let .success(data):
                    str = "\(data.firstName) \(data.lastName)"
                case .failure:
                    str = "Failure"
                }
            }
            return str
        case let .messageSenderChat(messageSenderChat):
            var str = ""
            try tdApi.getChat(chatId: messageSenderChat.chatId) {
                switch $0 {
                case let .success(data):
                    str = data.title
                case .failure:
                    str = "Failure"
                }
            }
            return str
        }
    }

    public func set(blocked: Bool) async throws {
        switch try await chatType {
        case let .chatTypePrivate(info):
            _ = try await tdApi.toggleMessageSenderIsBlocked(
                isBlocked: blocked,
                senderId: .messageSenderUser(.init(userId: info.userId))
            )
        case let .chatTypeSupergroup(info):
            _ = try await tdApi.toggleMessageSenderIsBlocked(
                isBlocked: blocked,
                senderId: .messageSenderChat(.init(chatId: info.supergroupId))
            )
        default:
            throw ChatServiceError.cantBeBlocked
        }
    }

    public func set(chatTitle: String) async throws {
        _ = try await tdApi.setChatTitle(chatId: chatId, title: chatTitle)
    }

    public func set(draft: DraftMessage?) async throws {
        _ = try await tdApi.setChatDraftMessage(chatId: chatId, draftMessage: draft, messageThreadId: nil)
    }

    // MARK: - Messages

    public var messageHistory: [Message] {
        get async throws {
            try await tdApi.getChatHistory(
                chatId: chatId,
                fromMessageId: 0,
                limit: 50,
                offset: 0,
                onlyLocal: false
            ).messages ?? []
        }
    }

    // MARK: - Chat info

    public var chatTitle: String = "" {
        didSet {
            Task {
                try await tdApi.setChatTitle(chatId: self.chatId, title: self.chatTitle)
            }
        }
    }

    public var draftMessage: DraftMessage? {
        get async throws {
            try await tdApi.getChat(chatId: chatId).draftMessage
        }
    }
    
    
    public var isChannel: Bool {
        get async throws {
            if case .chatTypeSupergroup(let info) = try await chatType {
                return info.isChannel
            } else {
                return false
            }
        }
    }

    public var chatId: Int64?

    public func set(chatId: Int64) {
        self.chatId = chatId
    }

    public var chatType: ChatType {
        get async throws {
            try await tdApi.getChat(chatId: chatId).type
        }
    }

    public var chatMemberCount: Int? {
        get async throws {
            switch try await chatType {
                case let .chatTypeBasicGroup(info):
                    return try await tdApi.getBasicGroupFullInfo(
                        basicGroupId: info.basicGroupId
                    ).members.count
                case let .chatTypeSupergroup(info):
                    return try await tdApi.getSupergroupFullInfo(
                        supergroupId: info.supergroupId
                    ).memberCount
                default:
                    return nil
            }
        }
    }
    
    public var chatPhoto: File? {
        get async throws {
            if let photo = try await getChat(by: chatId!).photo {
                return photo.small
            } else {
                return nil
            }
        }
    }

    public var protected: Bool {
        get async {
            true
        }
    }

    public var blocked: Bool {
        get async {
            true
        }
    }

    public init() {}
}
