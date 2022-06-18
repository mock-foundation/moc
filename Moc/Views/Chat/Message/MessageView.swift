//
//  MessageView.swift
//  Moc
//
//  Created by Егор Яковенко on 26.02.2022.
//

import SwiftUI
import TDLibKit
import Utilities

struct MessageView: View {
    @State var message: Moc.Message
    
    @State private var senderPhotoFileID: Int? = nil
    private let tdApi = TdApi.shared[0]

    @ViewBuilder
    var body: some View {
        HStack(alignment: .bottom, spacing: nil) {
            if !message.isOutgoing {
                Group {
                    if let senderPhotoFileID = senderPhotoFileID {
                        AsyncTdImage(id: senderPhotoFileID) { image in
                            image
                                .resizable()
                                .interpolation(.medium)
                                .antialiased(true)
                        }
                    } else {
                        ProfilePlaceholderView(
                            userId: message.sender.id,
                            firstName: message.sender.firstName,
                            lastName: message.sender.lastName ?? "",
                            style: .small
                        )
                    }
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                .padding(.leading, 4)
            }
            Group {
                switch message.content {
                    case let .messageText(info):
                        MessageBubbleView(sender: "\(message.sender.firstName) \(message.sender.lastName ?? "")", isOutgoing: message.isOutgoing) {
                            Text(info.text.text)
                                .textSelection(.enabled)
                                .if(message.isOutgoing) { view in
                                    view.foregroundColor(.white)
                                }
                        }
                    case let .messagePhoto(info):
                        MessageBubbleView(sender: "\(message.sender.firstName) \(message.sender.lastName ?? "")", isOutgoing: message.isOutgoing) {
                            VStack {
                                if info.photo.sizes.isEmpty == false {
                                    AsyncTdImage(id: info.photo.sizes[info.photo.sizes.endIndex - 1].photo.id) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                }
                                Text(info.caption.text)
                                    .if(message.isOutgoing) { view in
                                        view.foregroundColor(.white)
                                    }
                                    .multilineTextAlignment(.leading)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    case .messageUnsupported:
                        MessageBubbleView(sender: "\(message.sender.firstName) \(message.sender.lastName ?? "")", isOutgoing: message.isOutgoing) {
                            Text("Sorry, this message is unsupported.")
                                .if(message.isOutgoing) { view in
                                    view.foregroundColor(.white)
                                }
                        }
                    default:
                        MessageBubbleView(sender: "\(message.sender.firstName) \(message.sender.lastName ?? "")", isOutgoing: message.isOutgoing) {
                            Text("Sorry, this message is unsupported.")
                                .if(message.isOutgoing) { view in
                                    view.foregroundColor(.white)
                                }
                        }
                }
            }.frame(maxWidth: 300, alignment: message.isOutgoing ? .trailing : .leading)
        }
        .onReceive(SystemUtils.ncPublisher(for: .updateFile)) { notification in
            let update = notification.object as! UpdateFile
            
            if update.file.id == senderPhotoFileID {
                senderPhotoFileID = update.file.id
            }
        }
        .onAppear {
            Task {
                switch message.sender.type {
                    case .user:
                        let user = try await tdApi.getUser(userId: message.sender.id)
                        senderPhotoFileID = user.profilePhoto?.small.id
                    case .chat:
                        let chat = try await tdApi.getChat(chatId: message.sender.id)
                        senderPhotoFileID = chat.photo?.small.id
                }
            }
        }
    }
}
