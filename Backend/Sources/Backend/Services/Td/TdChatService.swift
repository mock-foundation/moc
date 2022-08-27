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

// swiftlint:disable function_body_length
public class TdChatService: ChatService {
    private var logger = Logs.Logger(category: "Services", label: "TdChatDataSource")
    private var tdApi = TdApi.shared
    
    public var updateSubject: PassthroughSubject<Update, Never> {
        tdApi.client.updateSubject
    }
    
    public func updateDraft(_ newDraft: TDLibKit.DraftMessage?, threadId: Int64? = nil) async throws {
        if let chatId {
            try await tdApi.setChatDraftMessage(
                chatId: chatId,
                draftMessage: newDraft,
                messageThreadId: nil)
        } else {
            throw ServiceError.noChatIdSet
        }
    }
    
    public func getUser(by id: Int64) async throws -> TDLibKit.User {
        return try await tdApi.getUser(userId: id)
    }
    
    public func getChat(by id: Int64) async throws -> TDLibKit.Chat {
        return try await tdApi.getChat(chatId: id)
    }
    
    public func sendTextMessage(
        _ message: FormattedText,
        clearDraft: Bool,
        disablePreview: Bool
    ) async throws -> Message {
        if let chatId {
            return try await tdApi.sendMessage(
                chatId: chatId,
                inputMessageContent: .text(.init(
                    clearDraft: clearDraft,
                    disableWebPagePreview: disablePreview,
                    text: message)),
                messageThreadId: 0,
                options: nil,
                replyMarkup: nil,
                replyToMessageId: 0)
        } else {
            throw ServiceError.noChatIdSet
        }
    }
    
    public func sendMedia(_ url: URL, caption: String) async throws -> Message {
        if let chatId {
            return try await tdApi.sendMessage(
                chatId: chatId,
                inputMessageContent: makeInputMessageContent(
                    for: url,
                    caption: FormattedText(entities: [], text: caption)),
                messageThreadId: nil,
                options: nil,
                replyMarkup: nil,
                replyToMessageId: nil)
        } else {
            throw ServiceError.noChatIdSet
        }
    }
    
    public func sendAlbum(_ urls: [URL], caption: String) async throws -> [Message]? {
        let messageContents: [InputMessageContent] = await urls.asyncMap { url in
            return await makeInputMessageContent(for: url, caption: FormattedText(entities: [], text: caption))
        }
        
        if let chatId {
            return try await tdApi.sendMessageAlbum(
                chatId: chatId,
                inputMessageContents: messageContents,
                messageThreadId: nil,
                onlyPreview: nil,
                options: nil,
                replyToMessageId: nil).messages
        } else {
            throw ServiceError.noChatIdSet
        }
    }
    
    public func setProtected(_ isProtected: Bool) async throws {
        if let chatId {
            try await tdApi.toggleChatHasProtectedContent(
                chatId: chatId,
                hasProtectedContent: isProtected)
        } else {
            throw ServiceError.noChatIdSet
        }
    }
    
    public func setBlocked(_ isBlocked: Bool) async throws {
        if let chatId {
            switch try await getChat(by: chatId).type {
                case let .private(info):
                    _ = try await tdApi.toggleMessageSenderIsBlocked(
                        isBlocked: isBlocked,
                        senderId: .user(.init(userId: info.userId))
                    )
                case let .supergroup(info):
                    _ = try await tdApi.toggleMessageSenderIsBlocked(
                        isBlocked: isBlocked,
                        senderId: .chat(.init(chatId: info.supergroupId))
                    )
                default:
                    throw ServiceError.cantBeBlocked
            }
        } else {
            throw ServiceError.noChatIdSet
        }
    }
    
    public func setChatTitle(_ title: String) async throws {
        if let chatId {
            try await tdApi.setChatTitle(chatId: chatId, title: title)
        } else {
            throw ServiceError.noChatIdSet
        }
    }
    
    public func setAction(_ action: TDLibKit.ChatAction) async throws {
        if let chatId {
            try await tdApi.sendChatAction(
                action: action,
                chatId: chatId,
                messageThreadId: nil)
        } else {
            throw ServiceError.noChatIdSet
        }
    }
    
    public func getMessage(by id: Int64) async throws -> TDLibKit.Message {
        if let chatId {
            return try await tdApi.getMessage(chatId: chatId, messageId: id)
        } else {
            throw ServiceError.noChatIdSet
        }
    }
    
    public func getMessageHistory() async throws -> [Message] {
        if let chatId {
            return try await tdApi.getChatHistory(
                chatId: chatId,
                fromMessageId: 0,
                limit: 50,
                offset: 0,
                onlyLocal: false
            ).messages ?? []
        } else {
            throw ServiceError.noChatIdSet
        }
    }
    
    public var chatId: Int64?
    
    private func makeInputMessageContent(for url: URL, caption: FormattedText) async -> InputMessageContent {
        var path = url.absoluteString
        path = String(path.suffix(from: .init(utf16Offset: 7, in: path))).removingPercentEncoding ?? ""
        
        let uti = UTType(url)
        logger.debug("UTType: \(String(describing: uti))")
        
        let inputGenerated: InputFile = .generated(InputFileGenerated(
            conversion: "copy",
            expectedSize: 0,
            originalPath: path))
        
        let messageDocument: InputMessageContent = .document(InputMessageDocument(
            caption: caption,
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
            
            return .photo(InputMessagePhoto(
                addedStickerFileIds: [],
                caption: caption,
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
            var size: CGSize?
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
            
            return .video(InputMessageVideo(
                addedStickerFileIds: [],
                caption: caption,
                duration: Int(CMTimeGetSeconds(asset.duration)),
                height: Int(size!.height),
                supportsStreaming: true,
                thumbnail: InputThumbnail(
                    height: Int(size!.height),
                    thumbnail: .generated(InputFileGenerated(
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
    
    public init() { }
}
