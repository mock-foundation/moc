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
    @State var message: [Moc.Message]
    
    // Internal state
    
    @State private var isMediaOpened = false
    @State private var senderPhotoFileID: Int?
    
    private let tdApi = TdApi.shared[0]
    
    private var avatarPlaceholder: some View {
        ProfilePlaceholderView(
            userId: message.first!.sender.id,
            firstName: message.first!.sender.firstName,
            lastName: message.first!.sender.lastName ?? "",
            style: .miniature)
    }
    
    func makeMessage<Content: View>(@ViewBuilder _ content: @escaping () -> Content) -> some View {
        HStack(alignment: .bottom, spacing: nil) {
            if message.first!.isOutgoing { Spacer() }
            if !message.first!.isOutgoing {
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
            MessageBubbleView(isOutgoing: message.first!.isOutgoing) {
                content()
            }
            .frame(maxWidth: 300, alignment: message.first!.isOutgoing ? .trailing : .leading)
            if !message.first!.isOutgoing { Spacer() }
        }
        .onReceive(SystemUtils.ncPublisher(for: .updateFile)) { notification in
            let update = notification.object as! UpdateFile
            
            if update.file.id == senderPhotoFileID {
                senderPhotoFileID = update.file.id
            }
        }
        .onAppear {
            Task {
                switch message.first!.sender.type {
                    case .user:
                        let user = try await tdApi.getUser(userId: message.first!.sender.id)
                        senderPhotoFileID = user.profilePhoto?.small.id
                    case .chat:
                        let chat = try await tdApi.getChat(chatId: message.first!.sender.id)
                        senderPhotoFileID = chat.photo?.small.id
                }
            }
        }
    }

    @ViewBuilder
    var body: some View {
        Group {
            switch message.first!.content {
                case let .messageText(info):
                    makeMessage {
                        VStack(alignment: .leading) {
                            if !message.first!.isOutgoing {
                                Text(message.first!.sender.name)
                                    .foregroundColor(Color(fromUserId: message.first!.sender.id))
                            }
                            Text(info.text.text)
                                .textSelection(.enabled)
                                .if(message.first!.isOutgoing) { view in
                                    view.foregroundColor(.white)
                                }
                        }.padding(8)
                    }
                case let .messagePhoto(info):
                    makeMessage {
                        VStack(spacing: 0) {
                            if !info.photo.sizes.isEmpty {
                                AsyncTdImage(
                                    id: info.photo.sizes[info.photo.sizes.endIndex - 1].photo.id
                                ) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .circular))
                                .onTapGesture {
                                    isMediaOpened = true
                                }
                                .sheet(isPresented: $isMediaOpened) {
                                    ZStack {
                                        AsyncTdQuickLookView(id: info.photo.sizes[info.photo.sizes.endIndex - 1].photo.id) {
                                            ProgressView()
                                        }
                                        Button {
                                            isMediaOpened = false
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 12))
                                                .padding(8)
                                        }
                                        .buttonStyle(.plain)
                                        .keyboardShortcut(.escape, modifiers: [])
                                        .background(.ultraThinMaterial, in: Circle())
                                        .clipShape(Circle())
                                        .hTrailing()
                                        .vTop()
                                        .padding()
                                    }
                                    .frame(width: 700, height: 500)
                                }
                            }
                            
                            Text(info.caption.text)
                                .if(message.first!.isOutgoing) { view in
                                    view.foregroundColor(.white)
                                }
                                .multilineTextAlignment(.leading)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                        }
                    }
                case .messageUnsupported:
                    makeMessage {
                        Text("Sorry, this message is unsupported.")
                            .if(message.first!.isOutgoing) { view in
                                view.foregroundColor(.white)
                            }
                            .padding(8)
                    }
                default:
                    makeMessage {
                        Text("Sorry, this message is unsupported.")
                            .if(message.first!.isOutgoing) { view in
                                view.foregroundColor(.white)
                            }
                            .padding(8)
                    }
            }
        }
        .if(message.first!.isOutgoing) { view in
            view.padding(.trailing)
        } else: { view in
            view.padding(.leading, 6)
        }
    }
}
