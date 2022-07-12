//
//  EmojiModel.swift
//  
//
//  Created by DariaMikots on 07.07.2022.
//

import Foundation

// MARK: - Emoji
public struct Emoji: Codable {
    public let totals: Int
    public let subCategories: [SubCategory]
    
    enum CodingKeys: String, CodingKey {
        case subCategories = "results"
        case totals
    }
}

// MARK: - SubCategory
public struct SubCategory: Codable {
    public let id: Int
    public let name, emoji, unicode: String
    public let category, subCategory: Category
    public let children: [Child]

    enum CodingKeys: String, CodingKey {
        case id, name, emoji, unicode, category
        case subCategory = "sub_category"
        case children
    }
}

// MARK: - Category
public struct Category: Codable {
    public let id: Int
    public let name: String
}

// MARK: - Child
public struct Child: Codable {
    public let id: Int
    public let name, emoji, unicode: String
}
