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

// swiftlint:disable type_body_length function_body_length
public class TdChatService: ChatService {
    public var updateSubject: PassthroughSubject<Update, Never> {
        tdApi.client.updateSubject
    }
    
    public func getMessage(by id: Int64) async throws -> Message {
        return try await tdApi.getMessage(chatId: chatId!, messageId: id)
    }
    
    public func setAction(_ action: ChatAction) async throws {
        _ = try await tdApi.sendChatAction(action: action, chatId: chatId, messageThreadId: nil)
    }
    
    public func sendMessage(_ message: String) async throws {
        _ = try await tdApi.sendMessage(
            chatId: chatId!,
            inputMessageContent: .text(
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
        _ = try await tdApi.sendMessage(
            chatId: chatId!,
            inputMessageContent: makeInputMessageContent(for: url, caption: FormattedText(entities: [], text: caption)),
            messageThreadId: nil,
            options: nil,
            replyMarkup: nil,
            replyToMessageId: nil
        )
    }
    
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
    
    public func sendAlbum(_ urls: [URL], caption: String) async throws {
        let messageContents: [InputMessageContent] = await urls.asyncMap { url in
            return await makeInputMessageContent(for: url, caption: FormattedText(entities: [], text: caption))
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

    public func set(blocked: Bool) async throws {
        switch try await chatType {
        case let .private(info):
            _ = try await tdApi.toggleMessageSenderIsBlocked(
                isBlocked: blocked,
                senderId: .user(.init(userId: info.userId))
            )
        case let .supergroup(info):
            _ = try await tdApi.toggleMessageSenderIsBlocked(
                isBlocked: blocked,
                senderId: .chat(.init(chatId: info.supergroupId))
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
            if case .supergroup(let info) = try await chatType {
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
                case let .basicGroup(info):
                    return try await tdApi.getBasicGroupFullInfo(
                        basicGroupId: info.basicGroupId
                    ).members.count
                case let .supergroup(info):
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
