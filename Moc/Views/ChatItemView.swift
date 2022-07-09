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
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .fixedSize()
                Spacer()
            }
            VStack(alignment: .leading) {
                HStack {
                    // swiftlint:disable empty_enum_arguments switch_case_alignment
                    Group {
                        switch chat.type {
                            case .private(_):
                                EmptyView()
                            case .basicGroup(_):
                                Image(systemName: "person.2")
                            case .supergroup(let info):
                                if info.isChannel {
                                    Image(systemName: "megaphone")
                                } else {
                                    Image(systemName: "person.2.fill")
                                }
                            case .secret(_):
                                Image(systemName: "lock")
                        }
                    }
                    .foregroundColor(isSelected ? .white : .primary)
                    Text(chat.title)
                        #if os(macOS)
                        .font(.title3)
                        .fontWeight(.bold)
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
        .onReceive(SystemUtils.ncPublisher(for: .updateChatLastMessage)) { notification in
            let update = notification.object as! UpdateChatLastMessage
            
            if update.chatId == chat.id {
                lastMessage = update.lastMessage
            }
        }
    }
}
