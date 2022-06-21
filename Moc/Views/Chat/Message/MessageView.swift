//
//  MessageView.swift
//  Moc
//
//  Created by Егор Яковенко on 26.02.2022.
//

import SwiftUI
import TDLibKit
import Logs
import Utilities

struct MessageView: View {
    @State var message: [Moc.Message]
    
    // Internal state
    
    struct OMFID: Identifiable {
        let id: Int
    }
    
    @State private var openedMediaFileID: OMFID?
    @State private var senderPhotoFileID: Int?
    
    private let tdApi = TdApi.shared[0]
    private let logger = Logger(category: "MessageView", label: "UI")
    
    private var avatarPlaceholder: some View {
        ProfilePlaceholderView(
            userId: message.first!.sender.id,
            firstName: message.first!.sender.firstName,
            lastName: message.first!.sender.lastName ?? "",
            style: .miniature)
    }
    
    private func makeMessage<Content: View>(@ViewBuilder _ content: @escaping () -> Content) -> some View {
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
            .frame(maxWidth: 350, alignment: message.first!.isOutgoing ? .trailing : .leading)
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
    
    private func makeImage(from info: MessagePhoto, contentMode: ContentMode = .fit) -> some View {
        ZStack {
            AsyncTdImage(
                id: info.photo.sizes[info.photo.sizes.endIndex - 1].photo.id
            ) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } placeholder: {
                ProgressView()
            }
        }
        .frame(minWidth: 0, maxWidth: 350, minHeight: 0, maxHeight: 200)
        .background {
            AsyncTdImage(
                id: info.photo.sizes[info.photo.sizes.endIndex - 1].photo.id
            ) { image in
                image
                    .resizable()
            } placeholder: {
                ProgressView()
            }.overlay {
                Color.clear
                    .background(.ultraThinMaterial, in: Rectangle())
            }
        }
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .circular))
        .onTapGesture {
            openedMediaFileID = OMFID(id: info.photo.sizes[info.photo.sizes.endIndex - 1].photo.id)
        }
    }
    
    private func getPhoto(from content: MessageContent) -> MessagePhoto? {
        if case .messagePhoto(let info) = content {
            return info
        } else {
            return nil
        }
    }
    
    // swiftlint:disable function_body_length cyclomatic_complexity
    private func makeMessagePhoto(from info: MessagePhoto) -> some View {
        makeMessage {
            VStack(spacing: 0) {
                // NOTE: all of this code is only for macOS Monterey
                // and iPadOS 15. It's a subject for change when I will
                // get familiar with new Layout API in macOS Ventura
                // and iPadOS 16, so I can build a better system for
                // organizing media in an album
                switch message.count { // go through all possible cases of media count in an album
                    case 1:
                        makeImage(from: getPhoto(from: message[0].content)!)
                    case 2:
                        HStack(spacing: 1) {
                            makeImage(from: getPhoto(from: message[0].content)!)
                            makeImage(from: getPhoto(from: message[1].content)!)
                        }
                    case 3:
                        HStack(spacing: 1) {
                            makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                            VStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                            }.frame(maxWidth: 100)
                        }
                    case 4:
                        VStack(spacing: 1) {
                            makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[3].content)!, contentMode: .fill)
                            }
                        }
                    case 5:
                        VStack(spacing: 1) {
                            makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[3].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[4].content)!, contentMode: .fill)
                            }
                        }
                    case 6:
                        VStack(spacing: 1) {
                            makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[3].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[4].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[5].content)!, contentMode: .fill)
                            }
                        }
                    case 7:
                        VStack(spacing: 1) {
                            makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[3].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[4].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[5].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[6].content)!, contentMode: .fill)
                            }
                        }
                    case 8:
                        VStack(spacing: 1) {
                            makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                            makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[3].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[4].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[5].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[6].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[7].content)!, contentMode: .fill)
                            }
                        }
                    case 9:
                        VStack(spacing: 1) {
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[3].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[4].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[5].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[6].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[7].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[8].content)!, contentMode: .fill)
                            }
                        }
                    case 10:
                        VStack(spacing: 1) {
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[3].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[4].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[5].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[6].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[7].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[8].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[9].content)!, contentMode: .fill)
                            }
                        }
                    default:
                        Image(systemName: "xmark")
                            .font(.system(size: 22))
                }
                
                if !info.caption.text.isEmpty {
                    Text(info.caption.text)
                        .if(message.first!.isOutgoing) { view in
                            view.foregroundColor(.white)
                        }
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
            }
            .sheet(item: $openedMediaFileID) { omfid in
                ZStack {
                    AsyncTdQuickLookView(id: omfid.id) {
                        ProgressView()
                    }
                    Button {
                        openedMediaFileID = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.escape, modifiers: [])
                    .background(.ultraThinMaterial, in: Circle())
                    .clipShape(Circle())
                    #if os(macOS)
                    .hTrailing()
                    #elseif os(iOS)
                    .hLeading()
                    #endif
                    .vTop()
                    .padding()
                }
                #if os(macOS)
                .frame(width: 800, height: 600)
                #endif
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
                    makeMessagePhoto(from: info)
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
