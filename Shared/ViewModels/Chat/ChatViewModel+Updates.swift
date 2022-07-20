//
//  ChatViewModel+Updates.swift
//  Moc
//
//  Created by Егор Яковенко on 08.07.2022.
//

import SwiftUI
import TDLibKit
import Utilities

extension ChatViewModel {
    func updateNewMessage(_ update: UpdateNewMessage) {
        logger.debug("UpdateNewMessage")
        let tdMessage = update.message
        logger.debug("Message chat ID: \(tdMessage.chatId), Chat ID: \(chatID)")
        guard tdMessage.chatId == chatID else {
            logger.debug("Message not for this chat")
            return
        }
        Task {
            var firstName = ""
            var lastName = ""
            var id: Int64 = 0
            var type: MessageSenderType = .user
            var replyMessage: ReplyMessage?
            
            let replyId = tdMessage.replyToMessageId
            if replyId != 0 {
                let tdReplyMessage = try await self.service.getMessage(by: replyId)
                switch tdReplyMessage.senderId {
                    case let .user(user):
                        let user = try await self.service.getUser(by: user.userId)
                        replyMessage = ReplyMessage(
                            id: replyId,
                            sender: MessageSender(
                                firstName: user.firstName,
                                lastName: user.lastName,
                                type: .user,
                                id: user.id),
                            content: tdReplyMessage.content)
                    case let .chat(chat):
                        let chat = try await self.service.getChat(by: chat.chatId)
                        replyMessage = ReplyMessage(
                            id: replyId,
                            sender: MessageSender(
                                firstName: chat.title,
                                lastName: nil,
                                type: .chat,
                                id: chat.id),
                            content: tdReplyMessage.content)
                }
            }
            
            switch tdMessage.senderId {
                case let .user(info):
                    let user = try await self.service.getUser(by: info.userId)
                    firstName = user.firstName
                    lastName = user.lastName
                    id = info.userId
                    type = .user
                case let .chat(info):
                    let chat = try await self.service.getChat(by: info.chatId)
                    firstName = chat.title
                    id = info.chatId
                    type = .chat
            }
            
            let message = Message(
                id: tdMessage.id,
                sender: MessageSender(
                    firstName: firstName,
                    lastName: lastName,
                    type: type,
                    id: id),
                content: tdMessage.content,
                isOutgoing: tdMessage.isChannelPost ? false : tdMessage.isOutgoing,
                date: Date(timeIntervalSince1970: TimeInterval(tdMessage.date)),
                mediaAlbumID: tdMessage.mediaAlbumId.rawValue,
                replyToMessage: replyMessage
            )
            
            DispatchQueue.main.async {
                self.messages.append([message])
                self.scrollToEnd()
            }
        }
        
        //            .chunked {
        //                let firstDay = Calendar.current.dateComponents([.day], from: $0.date).day
        //                let secondDay = Calendar.current.dateComponents([.day], from: $1.date).day
        //                guard firstDay != nil else { false }
        //                guard secondDay != nil else { false }
        //
        //                return firstDay! < secondDay!
        //            }
    }
    
    func updateChatAction(_ update: UpdateChatAction) {
        guard update.chatId == chatID else { return }
        
        if update.action == .cancel {
            chatActions.removeValue(forKey: update.senderId)
        } else {
            chatActions[update.senderId] = update.action
        }
    }
    
    func updateChatOnlineMemberCount(_ update: UpdateChatOnlineMemberCount) {
        guard update.chatId == chatID else { return }
        
        chatOnlineCount = update.onlineMemberCount
    }
}
