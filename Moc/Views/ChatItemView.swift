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
                Group {
                    if sidebarSize != .medium {
                        chatPhoto
                            .frame(width: sidebarSize == .small ? 36 : 54, height: sidebarSize == .small ? 36 : 54)
                    } else {
                        chatPhoto
                            .frame(width: 48, height: 48)
                    }
                }
                .clipShape(Circle())
                .fixedSize()
                Spacer()
            }
            VStack(alignment: .leading) {
                HStack {
                    let group = Group {
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
                    
                    
                    let text = Text(chat.title)
                        #if os(macOS)
                        .fontWeight(.bold)
                        #elseif os(iOS)
                        .fontWeight(.medium)
                        #endif
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    if sidebarSize != .medium {
                        Group {
                            group
                            text
                        }.font(.system(size: sidebarSize == .small ? 12 : 16))
                    } else {
                        group
                        text
                            #if os(macOS)
                            .font(.title3)
                            #endif
                    }
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
