//
//  ChatListItemSelectedKey.swift
//  Moc
//
//  Created by Егор Яковенко on 23.06.2022.
//

import SwiftUI

struct ChatListItemSelectedKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isChatListItemSelected: Bool {
        get { self[ChatListItemSelectedKey.self] }
        set { self[ChatListItemSelectedKey.self] = newValue }
    }
}
