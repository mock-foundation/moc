//
//  ChatListView.swift
//  Moc
//
//  Created by Егор Яковенко on 25.12.2021.
//

import SwiftUI
import TDLibKit
import Utilities

extension Foundation.Date {
    var hoursAndMinutes: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

struct ChatItemView: View {
    @State var chat: Chat
        
    @ViewBuilder
    private var chatPhoto: some View {
        if chat.photo != nil {
            TDImage(file: chat.photo!.small)
        } else {
            ProfilePlaceholderView(userId: chat.id, firstName: chat.title, lastName: "", style: .normal)
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            //                chat.chatIcon
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
                    switch chat.type {
                        case .chatTypePrivate(_):
                            EmptyView()
                        case .chatTypeBasicGroup(_):
                            Image(systemName: "person.2")
                        case .chatTypeSupergroup(let info):
                            if info.isChannel {
                                Image(systemName: "megaphone")
                            } else {
                                Image(systemName: "person.2.fill")
                            }
                        case .chatTypeSecret(_):
                            Image(systemName: "lock")
                    }
                    Text(chat.title)
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Image(/* chat.seen ? */ "MessageSeenIcon" /* : "MessageSentIcon" */)
                    Text(Date(timeIntervalSince1970: Double(chat.lastMessage?.date ?? 0)).hoursAndMinutes)
                        .foregroundColor(.secondary)
                }
                HStack {
                    VStack {
                        Text("last message preview")
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    Spacer()
                    VStack {
                        Spacer()
//                        if chat.isPinned {
//                            Image(systemName: "pin")
//                                .rotationEffect(.degrees(15))
//                        }
                    }
                }
            }
            Spacer()
        }
    }
}
