//
//  MockMainService.swift
//  
//
//  Created by Егор Яковенко on 08.06.2022.
//

import TDLibKit
import Caching

public class MockMainService: MainService {
    public init() { }
    public func getFilters() throws -> [ChatFilter] {
        return [ChatFilter(title: "Title", id: 0, iconName: "Travel", order: 0)]
    }
    
    public func getUnreadCounters() throws -> [Caching.UnreadCounter] {
        return [UnreadCounter(chats: 50, messages: 60, chatList: .filter(0))]
    }
}
