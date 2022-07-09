//
//  ChatViewModel+Interactions.swift
//  Moc
//
//  Created by Егор Яковенко on 08.07.2022.
//

import SwiftUI
import TDLibKit

extension ChatViewModel {
    func updateAction(with action: ChatAction) {
        Task {
            try await service.setAction(action)
        }
    }
    
    func updateDraft() {
        Task {
            try await service.set(draft: .init(
                date: Int(Date.now.timeIntervalSince1970),
                inputMessageText: .text(.init(
                    clearDraft: true,
                    disableWebPagePreview: false,
                    text: .init(entities: [], text: inputMessage))),
                replyToMessageId: 0))
        }
    }
    
    func sendMessage() {
        Task {
            do {
                if inputMedia.isEmpty {
                    try await service.sendMessage(inputMessage)
                } else {
                    if inputMedia.count > 1 {
                        try await service.sendAlbum(inputMedia, caption: inputMessage)
                    } else {
                        try await service.sendMedia(inputMedia.first!, caption: inputMessage)
                    }
                }
                DispatchQueue.main.async { [self] in
                    inputMessage = ""
                    inputMedia.removeAll()
                    scrollToEnd()
                }
            } catch {
                let tdError = error as! TDLibKit.Error
                logger.error("Code: \(tdError.code), message: \(tdError.message)")
            }
        }
    }
}
