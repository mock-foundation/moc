//
//  TdMainService.swift
//  
//
//  Created by Егор Яковенко on 03.06.2022.
//

import TDLibKit
import Caching
import GRDB

public class TdMainService: MainService {
    private var tdApi = TdApi.shared[0]
    private var cache = CacheService.shared
    
    public init() { }
    
    public func getFilters() throws -> [ChatFilter] {
        let unreads = try cache.getRecords(as: UnreadCounter.self)
        return try cache.getRecords(as: Caching.ChatFilter.self, ordered: [Column("order").asc])
            .map { record in
                ChatFilter(
                    title: record.title,
                    id: record.id,
                    iconName: record.iconName,
                    unreadCount: unreads.first { unread in
                        switch unread.chatList {
                            case let .filter(id):
                                return id == record.id
                            default: return false
                        }
                    }?.chats ?? 0
                )
            }
    }
}
