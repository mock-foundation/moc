//
//  ChatListView.swift
//  Moc
//
//  Created by Егор Яковенко on 25.12.2021.
//

import SwiftUI

extension Date {
	var hoursAndMinutes: String {
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		return formatter.string(from: self)
	}
}

struct ChatItemView: View {
	@State var chat: ChatItem
		
	var body: some View {
		HStack(alignment: .top) {
				chat.chatIcon
					.resizable()
					.frame(width: 56, height: 56)
					.clipShape(Circle())
					.fixedSize()
			VStack(alignment: .leading) {
				HStack {
					switch chat.type {
						case .privateChat:
							EmptyView()
						case .group:
							Image(systemName: "person.2")
						case .superGroup:
							Image(systemName: "person.2.fill")
						case .channel:
							Image(systemName: "megaphone")
					}
					Text(chat.name)
						.font(.title3)
						.fontWeight(.bold)
					Spacer()
//					Image(chat.seen ? "MessageSeenIcon" : "MessageSentIcon")
					Text(chat.time.hoursAndMinutes)
						.foregroundColor(.secondary)
				}
				HStack {
					VStack {
						Text(chat.messagePreview)
							.multilineTextAlignment(.leading)
							.fixedSize(horizontal: false, vertical: true)
							.lineLimit(2)
							.foregroundColor(.secondary)
						Spacer()
					}
					Spacer()
					VStack {
						Spacer()
						if chat.isPinned {
							Image(systemName: "pin")
								.rotationEffect(.degrees(15))
						}
					}
				}
			}
			Spacer()
		}
	}
}

struct ChatListView_Previews: PreviewProvider {
	static var previews: some View {
		ChatItemView(chat: ChatItem(id: UUID(), name: "Chat lol", messagePreview: "Something was written here", sender: "DirectName", showSender: true, type: .group, chatIcon: Image(systemName: "folder"), isPinned: true, time: Date(timeIntervalSinceNow: 100), seen: true))
			.frame(width: 300)
	}
}
