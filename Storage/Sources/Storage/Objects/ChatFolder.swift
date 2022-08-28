//
//  ChatFolder.swift
//  
//
//  Created by Егор Яковенко on 31.05.2022.
//

import GRDB

public struct ChatFolder: Codable, FetchableRecord, PersistableRecord {
    public var title: String
    public var id: Int
    public var iconName: String
    public var order: Int
    
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
