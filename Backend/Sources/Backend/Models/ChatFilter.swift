//
//  ChatFilter.swift
//  
//
//  Created by Егор Яковенко on 03.06.2022.
//

public struct ChatFilter: Hashable, Identifiable {
    public let title: String
    public let id: Int
    public let iconName: String
    public let unreadCount: Int
    
    public init(
        title: String,
        id: Int,
        iconName: String,
        unreadCount: Int
    ) {
        self.title = title
        self.id = id
        self.iconName = iconName
        self.unreadCount = unreadCount
    }
}
