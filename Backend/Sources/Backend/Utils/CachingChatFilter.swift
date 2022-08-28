//
//  CachingChatFilter.swift
//
//
//  Created by Егор Яковенко on 31.05.2022.
//

import Storage
import TDLibKit

extension TDLibKit.ChatFilterInfo {
    init(from cached: Storage.ChatFolder) {
        self.init(
            iconName: cached.iconName,
            id: cached.id,
            title: cached.title
        )
    }
}
