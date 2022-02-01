//
//  MessageContent.swift
//
//
//  Created by Егор Яковенко on 01.02.2022.
//

import TDLibKit

public enum MessageContent {
    case text(MessageText)
    case unsupported
}

extension MessageContent {
    init(_ from: TDLibKit.MessageContent) {
        switch from {
        case let .messageText(text):
            self = .text(text)
        case .messageUnsupported:
            self = .unsupported
        default:
            self = .unsupported
        }
    }
}
