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
    public let name: String
    public let type: MessageSenderType
    public let id: Int64
}
