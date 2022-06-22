//
//  MessageSender.swift
//
//
//  Created by Егор Яковенко on 01.02.2022.
//

public enum MessageSenderType: Hashable, Equatable {
    case user
    case chat
}

public struct MessageSender: Hashable, Equatable {
    public let firstName: String
    /// Should be set to nil if it's a group/channel, 'cuz they just have a title
    public let lastName: String?
    public let type: MessageSenderType
    public let id: Int64
    
    var name: String {
        if let lastName = lastName {
            return "\(firstName) \(lastName)"
        } else {
            return firstName
        }
    }
}
