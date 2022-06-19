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
    
    // Internal state
    
    @State private var isMediaOpened = false
    
//    @State private var imageScale: CGFloat = 1
//    @State private var imagePosition = CGPoint(x: 0, y: 0)
//    @GestureState private var pointerLocation: CGPoint? = nil
//    @GestureState private var startLocation: CGPoint? = nil
//
//    var simpleDrag: some Gesture {
//        DragGesture()
//            .onChanged { value in
//                var newLocation = startLocation ?? imagePosition
//                newLocation.x += value.translation.width
//                newLocation.y += value.translation.height
//                self.imagePosition = newLocation
//            }.updating($startLocation) { (value, startLocation, transaction) in
//                startLocation = startLocation ?? imagePosition
//            }
//    }
//
//    var pointerDrag: some Gesture {
//        DragGesture()
//            .updating($pointerLocation) { (value, fingerLocation, transaction) in
//                fingerLocation = value.location
//            }
//    }
    
    @State private var senderPhotoFileID: Int?
    private let tdApi = TdApi.shared[0]
    
    private var avatarPlaceholder: some View {
        ProfilePlaceholderView(
            userId: message.sender.id,
            firstName: message.sender.firstName,
            lastName: message.sender.lastName ?? "",
            style: .miniature)
    }
    
    func makeMessage<Content: View>(@ViewBuilder _ content: @escaping () -> Content) -> some View {
        HStack(alignment: .bottom, spacing: nil) {
            if message.isOutgoing { Spacer() }
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
                content()
            }
            .frame(maxWidth: 300, alignment: message.isOutgoing ? .trailing : .leading)
            if !message.isOutgoing { Spacer() }
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

    @ViewBuilder
    var body: some View {
        switch message.content {
            case let .messageText(info):
                makeMessage {
                    VStack(alignment: .leading) {
                        if !message.isOutgoing {
                            Text(message.sender.name)
                                .foregroundColor(Color(fromUserId: message.sender.id))
                        }
                        Text(info.text.text)
                            .textSelection(.enabled)
                            .if(message.isOutgoing) { view in
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
                                    AsyncTdImage(
                                        id: info.photo.sizes[info.photo.sizes.endIndex - 1].photo.id
                                    ) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        ProgressView()
                                    }
//                                    .position(imagePosition)
//                                    .scaleEffect(imageScale)
//                                    .gesture(simpleDrag.simultaneously(with: pointerDrag))
//                                    .gesture(MagnificationGesture().onChanged { value in
//                                        imageScale = value
//                                    })
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
                                .onTapGesture {
                                    isMediaOpened = false
                                }
                            }
                        }
                        
                        Text(info.caption.text)
                            .if(message.isOutgoing) { view in
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
                        .if(message.isOutgoing) { view in
                            view.foregroundColor(.white)
                        }
                        .padding(8)
                }
            default:
                makeMessage {
                    Text("Sorry, this message is unsupported.")
                        .if(message.isOutgoing) { view in
                            view.foregroundColor(.white)
                        }
                        .padding(8)
                }
        }
    }
}
