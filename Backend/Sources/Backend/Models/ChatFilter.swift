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
    public let order: Int
    
    public init(
        title: String,
        id: Int,
        iconName: String,
        order: Int
    ) {
        self.title = title
        self.id = id
        self.iconName = iconName
        self.order = order
    }
}
