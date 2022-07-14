//
//  EmojiNetworking.swift
//  
//
//  Created by DariaMikots on 07.07.2022.
//

import Foundation

enum EmojiEndpoints {
    case name(name: String, limit: String)
    case getFavorite
}

extension EmojiEndpoints: Endpoint {
    var baseURL: String {
        "https://"
    }
    var path: String {
        switch self {
        case let .name(name, limit):
            return "api.emojisworld.fr/v1/search?q=\(name)&limit=\(limit)"
        case .getFavorite:
            return "api.emojisworld.fr/v1/popular?categories=1,2,3,4,5,6,7,8&sub_categories=1,2,3,4,5,6,7,8"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .name, .getFavorite:
            return .get
        }
    }

    var header: [String: String] {
        switch self {
        case .name, .getFavorite:
            return [:]
        }
    }

    var body: [String: String]? {
        switch self {
        case .name, .getFavorite:
            return nil
        }
    }
}
