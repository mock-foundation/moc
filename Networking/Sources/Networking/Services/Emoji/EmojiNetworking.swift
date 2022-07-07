//
//  EmojiNetworking.swift
//  
//
//  Created by DariaMikots on 07.07.2022.
//

import Foundation

enum EmojiEndpoints {
    case name(name: String, limit: String)
}

extension EmojiEndpoints: Endpoint {
    var baseURL: String {
        "https://"
    }
    var path: String {
        switch self {
        case let .name(name, limit):
            return "api.emojisworld.fr/v1/search?q=\(name)&limit=\(limit)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .name:
            return .get
        }
    }

    var header: [String: String] {
        switch self {
        case .name:
            return [:]
        }
    }

    var body: [String: String] {
        switch self {
        case .name:
            return [:]
        }
    }
}
