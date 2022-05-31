//
//  CachingChatFilter.swift
//
//
//  Created by Егор Яковенко on 31.05.2022.
//

import Caching
import TDLibKit

extension TDLibKit.ChatFilterInfo {
    init(from cached: Caching.ChatFilter) {
        self.init(
            iconName: cached.iconName,
            id: cached.id,
            title: cached.title
        )
    }
}
