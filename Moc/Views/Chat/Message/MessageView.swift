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
    
    @State private var senderPhotoFileID: Int?
    private let tdApi = TdApi.shared[0]
    
    private var avatarPlaceholder: some View {
        ProfilePlaceholderView(
            userId: message.sender.id,
            firstName: message.sender.firstName,
            lastName: message.sender.lastName ?? "",
            style: .miniature)
    }

    @ViewBuilder
    var body: some View {
        HStack(alignment: .bottom, spacing: nil) {
            if !message.isOutgoing {
                Group {
                    if senderPhotoFileID != nil {
                        AsyncTdImage(id: senderPhotoFileID!) { image in
                            image
                                .resizable()
                        } placeholder: {
                            avatarPlaceholder
                        }
                    } else {
                        avatarPlaceholder
                    }
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                .padding(.leading, 4)
            }
            
            MessageBubbleView(isOutgoing: message.isOutgoing) {
                switch message.content {
                    case let .messageText(info):
                        Text(info.text.text)
                            .textSelection(.enabled)
                            .if(message.isOutgoing) { view in
                                view.foregroundColor(.white)
                            }
                            .padding(8)
                    case let .messagePhoto(info):
                        VStack(spacing: 0) {
                            if info.photo.sizes.isEmpty == false {
                                AsyncTdImage(id: info.photo.sizes[info.photo.sizes.endIndex - 1].photo.id) {
                                    $0
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            Text(info.caption.text)
                                .if(message.isOutgoing) { view in
                                    view.foregroundColor(.white)
                                }
                                .multilineTextAlignment(.leading)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                        }
                    case .messageUnsupported:
                        Text("Sorry, this message is unsupported.")
                            .if(message.isOutgoing) { view in
                                view.foregroundColor(.white)
                            }
                            .padding(8)
                    default:
                        Text("Sorry, this message is unsupported.")
                            .if(message.isOutgoing) { view in
                                view.foregroundColor(.white)
                            }
                            .padding(8)
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
