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
    func updateNewMessage(notification: NCPO) {
        logger.debug(notification.name.rawValue)
        let tdMessage = (notification.object as? UpdateNewMessage)!.message
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
            
            if let id = tdMessage.replyToMessageId, id != 0 {
                let tdReplyMessage = try await self.service.getMessage(by: id)
                switch tdReplyMessage.senderId {
                    case let .user(user):
                        let user = try await self.service.getUser(by: user.userId)
                        replyMessage = ReplyMessage(
                            id: id,
                            sender: "\(user.firstName) \(user.lastName)",
                            content: tdReplyMessage.content)
                    case let .chat(chat):
                        let chat = try await self.service.getChat(by: chat.chatId)
                        replyMessage = ReplyMessage(
                            id: id,
                            sender: chat.title,
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
}
