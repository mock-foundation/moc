//
//  EmojiService.swift
//  Moc
//
//  Created by DariaMikots on 06.07.2022.
//

import Foundation
import Networking

protocol EmojiServiceable {
    
    func getEmoji(_ name: String,_ length: String) async throws -> [Emoji]
}

struct EmojiService: HTTPClient, EmojiServiceable {

    func getEmoji(_ name: String, _ length: String) async throws -> [Emoji] {
        return try await sendRequest(endpoint: EmojiEndpoints.name(name: name, limit: length), responseModel: [Emoji].self)
    }
}

