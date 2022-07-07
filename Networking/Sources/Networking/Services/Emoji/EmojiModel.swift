//
//  EmojiModel.swift
//  
//
//  Created by DariaMikots on 07.07.2022.
//

import Foundation

public struct Emoji: Decodable, Hashable {
    
    var id = UUID()
    var emoji: String
    
    init(emoji: String){
        self.emoji = emoji
    }
    
    private enum CodingKeys: String, CodingKey {
        case emoji
    }
}
