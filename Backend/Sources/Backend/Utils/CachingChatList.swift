//
//  CachingChatList.swift
//  
//
//  Created by Егор Яковенко on 05.06.2022.
//

import Storage
import TDLibKit

public extension Storage.ChatList {
    static func from(tdChatList: TDLibKit.ChatList) -> Self {
        switch tdChatList {
            case .main:
                return .main
            case .archive:
                return .archive
            case let .filter(info):
                return .folder(info.chatFilterId)
        }
    }
}
