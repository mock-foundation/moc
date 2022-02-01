//
//  Message.swift
//  
//
//  Created by Егор Яковенко on 01.02.2022.
//

import TDLibKit
import Foundation

public struct Message: Identifiable {
    public let id: Int64
    public let sender: MessageSender
    public let content: MessageContent
    public let isOutgoing: Bool
}
