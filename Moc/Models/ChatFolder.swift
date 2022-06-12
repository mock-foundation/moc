//
//  ChatFolder.swift
//  Moc
//
//  Created by Егор Яковенко on 08.06.2022.
//

import Caching

struct ChatFolder: Hashable, Identifiable {
    var title: String
    var id: Int
    var iconName: String
    var unreadCounter: Int
}
