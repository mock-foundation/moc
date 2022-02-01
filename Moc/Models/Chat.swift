//
//  Chat.swift
//
//
//  Created by Егор Яковенко on 01.02.2022.
//

struct Chat: Identifiable {
    let id: Int64
    let title: String
    let memberCount: Int?
    let type: ChatType
    let lastMessage: Message?
}

extension Chat: Equatable {
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        return lhs.id == rhs.id
    }
}
