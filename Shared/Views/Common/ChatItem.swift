//
//  ChatListView.swift
//  Moc
//
//  Created by Егор Яковенко on 25.12.2021.
//

import SwiftUI
import Utilities
import Backend
import Defaults

extension Foundation.Date {
    var hoursAndMinutes: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

private extension SidebarSize {
    var mainFont: Font {
        switch self {
            case .small:
                return .system(size: 12)
            case .medium:
                return .title3
            case .large:
                return .system(size: 16)
        }
    }
    
    var iconFont: Font {
        switch self {
            case .small:
                return .system(size: 12)
            case .medium:
                return .system(.body)
            case .large:
                return .system(size: 16)
        }
    }
    
    var chatPhotoSize: CGFloat {
        switch self {
            case .small:
                return 36
            case .medium:
                return 48
            case .large:
                return 54
        }
    }
}

struct ChatItem: View {
    let chat: Chat
    
    @State private var lastMessage: TDLibKit.Message?
    @State private var sidebarSize: SidebarSize = .medium
    
    private let tdApi = TdApi.shared
    
    @Environment(\.isChatListItemSelected) var isSelected
    
    private var placeholder: some View {
        ProfilePlaceholderView(userId: chat.id, firstName: chat.title, lastName: "", style: .normal)
    }
        
    @ViewBuilder
    private var chatPhoto: some View {
        if chat.photo != nil {
            AsyncTdImage(id: chat.photo!.small.id) { image in
                image
                    .resizable()
                    .interpolation(.medium)
                    .antialiased(true)
            } placeholder: {
                placeholder
            }
        } else {
            placeholder
        }
    }
    
    @State private var sender: String?
    
    init(chat: Chat) {
        self.chat = chat
        self.lastMessage = chat.lastMessage
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                Spacer()
                chatPhoto
                .frame(
                    width: sidebarSize.chatPhotoSize,
                    height: sidebarSize.chatPhotoSize)
                .clipShape(Circle())
                .fixedSize()
                Spacer()
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Label {
                        Text(chat.title)
                            #if os(macOS)
                            .fontWeight(.bold)
                            .font(sidebarSize.mainFont)
                            #elseif os(iOS)
                            .fontWeight(.medium)
                            #endif
                    } icon: {
                        Group {
                            switch chat.type {
                                case .private:
                                    EmptyView()
                                case .basicGroup:
                                    Image(systemName: "person.2")
                                case .supergroup(let info):
                                    if info.isChannel {
                                        Image(systemName: "megaphone")
                                    } else {
                                        Image(systemName: "person.2.fill")
                                    }
                                case .secret:
                                    Image(systemName: "lock")
                            }
                        }
                        .font(sidebarSize.iconFont)
                    }
                    .foregroundColor(isSelected ? .white : .primary)
                    Spacer()
//                    Image(/* chat.seen ? */ "MessageSeenIcon" /* : "MessageSentIcon" */)
                    Text(Date(timeIntervalSince1970: Double(lastMessage?.date ?? 0)).hoursAndMinutes)
                        .font(sidebarSize == .large ? .body : .caption)
                        .foregroundColor(isSelected ? .white.darker(by: 20) : .secondary)
                }
                .padding(.top, 4)
                VStack(alignment: .leading, spacing: 2) {
                    if chat.type.isGroup {
                        if let sender {
                            Text(sender)
                                .fontWeight(.medium)
                                .foregroundColor(isSelected ? .white : .primary)
                        }
                    }
                    Group {
                        switch lastMessage?.content {
                            case let .text(info):
                                Text(info.text.text)
                            case let .photo(info):
                                Label {
                                    if !info.caption.text.isEmpty {
                                        Text(info.caption.text)
                                    } else {
                                        Text("Photo")
                                    }
                                } icon: {
                                    if let minithumbnail = info.photo.minithumbnail {
                                        Image(data: minithumbnail.data)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 15, height: 15)
                                            .clipShape(RoundedRectangle(cornerRadius: 2))
                                    } else {
                                        Image(systemName: "photo")
                                    }
                                }
                            case let .video(info):
                                Label {
                                    if !info.caption.text.isEmpty {
                                        Text(info.caption.text)
                                    } else {
                                        Text("Video")
                                    }
                                } icon: {
                                    if let minithumbnail = info.video.minithumbnail {
                                        Image(data: minithumbnail.data)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 15, height: 15)
                                            .clipShape(RoundedRectangle(cornerRadius: 2))
                                            .overlay {
                                                Image(systemName: "play.fill")
                                                    .font(.system(size: 8))
                                                    .foregroundColor(.white)
                                            }
                                    } else {
                                        Image(systemName: "play.square")
                                    }
                                }
                            case let .document(info):
                                Label {
                                    if !info.caption.text.isEmpty {
                                        Text(info.caption.text)
                                    } else {
                                        Text("Document")
                                    }
                                } icon: {
                                    if let minithumbnail = info.document.minithumbnail {
                                        Image(data: minithumbnail.data)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 15, height: 15)
                                            .clipShape(RoundedRectangle(cornerRadius: 2))
                                    } else {
                                        Image(systemName: "doc")
                                    }
                                }
                            case let .sticker(info):
                                Text(info.sticker.emoji) + Text("Sticker")
                            default:
                                Text(Constants.unsupportedMessage)
                        }
                    }
                    .foregroundColor(isSelected ? .white.darker(by: 20) : .secondary)
                }
                
//                    VStack {
//                        Spacer()
//                        if chat.isPinned {
//                            Image(systemName: "pin")
//                                .rotationEffect(.degrees(15))
//                        }
//                    }
            }
        }
        .animation(.fastStartSlowStop(), value: sidebarSize)
        .onAppear {
            Task {
                if lastMessage == nil {
                    lastMessage = try await tdApi.getChat(chatId: chat.id).lastMessage
                }
            }
        }
        .onChange(of: lastMessage) { value in
            Task {
                switch value?.senderId {
                    case let .chat(info):
                        sender = try await tdApi.getChat(chatId: info.chatId).title
                    case let .user(info):
                        let user = try await tdApi.getUser(userId: info.userId)
                        sender = user.firstName + " " + user.lastName
                    default: break
                }
            }
        }
        .onReceive(tdApi.client.updateSubject) { update in
            if case let .chatLastMessage(info) = update {
                if info.chatId == chat.id {
                    lastMessage = info.lastMessage
                }
            }
        }
        .onReceive(Defaults.publisher(.sidebarSize)) { value in
            sidebarSize = SidebarSize(rawValue: value.newValue) ?? .medium
        }
    }
}
