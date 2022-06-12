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
        return try cache.getRecords(as: Caching.ChatFilter.self, ordered: [Column("order").asc])
            .map { record in
                ChatFilter(
                    title: record.title,
                    id: record.id,
                    iconName: record.iconName,
                    order: record.order
                )
            }
    }
    
    public func getUnreadCounters() throws -> [UnreadCounter] {
        return try cache.getRecords(as: UnreadCounter.self)
    }
}
