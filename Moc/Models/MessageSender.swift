//
//  MessageSender.swift
//
//
//  Created by Егор Яковенко on 01.02.2022.
//

public enum MessageSenderType {
    case user
    case chat
}

public struct MessageSender {
    public let firstName: String
    /// Should be set to nil if it's a group/channel, 'cuz they just have a title
    public let lastName: String?
    public let type: MessageSenderType
    public let id: Int64
}
