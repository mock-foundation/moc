//
//  CachingChatList.swift
//  
//
//  Created by Егор Яковенко on 05.06.2022.
//

import Caching
import TDLibKit

extension Caching.ChatList {
    static func from(tdChatList: TDLibKit.ChatList) -> Self {
        switch tdChatList {
            case .chatListMain:
                return .main
            case .chatListArchive:
                return .archive
            case let .chatListFilter(info):
                return .filter(info.chatFilterId)
        }
    }
}
