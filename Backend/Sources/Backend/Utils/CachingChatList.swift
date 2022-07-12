//
//  CachingChatList.swift
//  
//
//  Created by Егор Яковенко on 05.06.2022.
//

import Caching
import TDLibKit

public extension Caching.ChatList {
    static func from(tdChatList: TDLibKit.ChatList) -> Self {
        switch tdChatList {
            case .main:
                return .main
            case .archive:
                return .archive
            case let .filter(info):
                return .filter(info.chatFilterId)
        }
    }
}
