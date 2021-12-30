//
//  Chat.swift
//  Moc
//
//  Created by Егор Яковенко on 25.12.2021.
//

import SwiftUI

enum ChatType {
	case privateChat
	case group
	case superGroup
	case channel
}

struct ChatItem: Identifiable {
	var id: UUID
	
	let name: String
	let messagePreview: String
	let sender: String?
	let showSender: Bool
	let type: ChatType
	let chatIcon: Image
	let isPinned: Bool
	let time: Date
	let seen: Bool
}
