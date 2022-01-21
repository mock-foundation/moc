//
//  ChatListView.swift
//  Moc
//
//  Created by Егор Яковенко on 25.12.2021.
//

import SwiftUI
import TDLibKit

extension Foundation.Date {
	var hoursAndMinutes: String {
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		return formatter.string(from: self)
	}
}

struct ChatItemView: View {
	@State var chat: Chat

	var body: some View {
		HStack(alignment: .top) {
//				chat.chatIcon
            Image("MockChatPhoto")
					.resizable()
					.frame(width: 52, height: 52)
					.clipShape(Circle())
					.fixedSize()
			VStack(alignment: .leading) {
				HStack {
                    // swiftlint:disable empty_enum_arguments switch_case_alignment
					switch chat.type {
                    case .chatTypePrivate( _):
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
                        .foregroundStyle(Color.primary)
					Spacer()
//					Image(chat.seen ? "MessageSeenIcon" : "MessageSentIcon")
                    Text(Date(timeIntervalSince1970: Double(chat.lastMessage?.date ?? 0)).hoursAndMinutes)
                        .foregroundStyle(Color.secondary)
                }
				HStack {
					VStack {
                        Text("mock last message")
							.multilineTextAlignment(.leading)
							.fixedSize(horizontal: false, vertical: true)
							.lineLimit(2)
                            .foregroundStyle(Color.secondary)
						Spacer()
					}
					Spacer()
					VStack {
						Spacer()
//						if chat.isPinned {
//							Image(systemName: "pin")
//								.rotationEffect(.degrees(15))
//						}
					}
				}
			}
			Spacer()
		}
	}
}
