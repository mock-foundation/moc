//
//  EmojiService.swift
//
//
//  Created by DariaMikots on 07.07.2022.
//

import Foundation

public protocol EmojiServiceable {
    func getEmoji(
        _ name: String,
        _ length: String
    ) async throws -> Emoji
    func getFavorite() async throws -> Emoji 
}

public struct EmojiService: HTTPClient, EmojiServiceable {
    public init() {}
    public func getEmoji(
        _ name: String,
        _ length: String
    ) async throws -> Emoji {
        return try await sendRequest(
            endpoint: EmojiEndpoints.name(name: name,
                                          limit: length),
            responseModel: Emoji.self
        )
    }
        public func getFavorite(  ) async throws -> Emoji {
            return try await sendRequest(
                endpoint: EmojiEndpoints.getFavorite,
                responseModel: Emoji.self
            )
    }
}
