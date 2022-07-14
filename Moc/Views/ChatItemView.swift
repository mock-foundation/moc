//
//  ChatListView.swift
//  Moc
//
//  Created by Егор Яковенко on 25.12.2021.
//

import SwiftUI
import TDLibKit
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

struct ChatItemView: View {
    let chat: Chat
    
    @State private var lastMessage: TDLibKit.Message?
    @State private var sidebarSize: SidebarSize = .medium
    
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
            VStack(alignment: .leading) {
                HStack {
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
                    .foregroundColor(isSelected ? .white : .primary)
                    .font(sidebarSize.iconFont)
                    
                    
                    Text(chat.title)
                        #if os(macOS)
                        .fontWeight(.bold)
                        .font(sidebarSize.mainFont)
                        #elseif os(iOS)
                        .fontWeight(.medium)
                        #endif
                        .foregroundColor(isSelected ? .white : .primary)
                    Spacer()
//                    Image(/* chat.seen ? */ "MessageSeenIcon" /* : "MessageSentIcon" */)
                    Text(Date(timeIntervalSince1970: Double(lastMessage?.date ?? 0)).hoursAndMinutes)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.darker(by: 20) : .secondary)
                }
                .padding(.vertical, 6)
                HStack {
                    VStack {
                        Spacer()
                        lastMessage?.content.preview
                            .foregroundColor(isSelected ? .white.darker(by: 20) : .secondary)
                        Spacer()
                    }
                    Spacer()
//                    VStack {
//                        Spacer()
//                        if chat.isPinned {
//                            Image(systemName: "pin")
//                                .rotationEffect(.degrees(15))
//                        }
//                    }
                }
            }
        }
        .onReceive(TdApi.shared[0].client.updateSubject) { update in
            if case let .chatLastMessage(info) = update {
                if info.chatId == chat.id {
                    lastMessage = info.lastMessage
                }
            }
        }
        .onReceive(Defaults.publisher(.sidebarSize)) { value in
            sidebarSize = SidebarSize(rawValue: value.newValue) ?? .medium
        }
        .animation(.fastStartSlowStop, value: sidebarSize)
    }
}
