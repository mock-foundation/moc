//
//  EmojiModel.swift
//  
//
//  Created by DariaMikots on 07.07.2022.
//

import Foundation

// MARK: - Emoji
public struct Emoji: Codable {
    let totals: Int
    let subCategories: [SubCategory]
}

// MARK: - SubCategory
struct SubCategory: Codable {
    let id: Int
    let name, emoji, unicode: String
    let category, subCategory: Category
    let children: [Child]

    enum CodingKeys: String, CodingKey {
        case id, name, emoji, unicode, category
        case subCategory = "sub_category"
        case children
    }
}

// MARK: - Category
struct Category: Codable {
    let id: Int
    let name: String
}

// MARK: - Child
struct Child: Codable {
    let id: Int
    let name, emoji, unicode: String
}
