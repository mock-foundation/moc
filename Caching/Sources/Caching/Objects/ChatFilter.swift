//
//  ChatFilter.swift
//  
//
//  Created by Егор Яковенко on 31.05.2022.
//

import GRDB

public struct ChatFilter: Codable, FetchableRecord, PersistableRecord {
    public let title: String
    public let id: Int
    public let iconName: String
    
    public init(
        title: String,
        id: Int,
        iconName: String
    ) {
        self.title = title
        self.id = id
        self.iconName = iconName
    }
}
