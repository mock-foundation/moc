//
//  ChatType+IsGroup.swift
//  Moc
//
//  Created by Егор Яковенко on 16.07.2022.
//

import TDLibKit

extension TDLibKit.ChatType {
    var isGroup: Bool {
        switch self {
            case .basicGroup:
                return true
            case let .supergroup(info):
                return !info.isChannel
            default:
                return false
        }
    }
}
