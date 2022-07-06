//
//  EmojiModel.swift
//  Moc
//
//  Created by DariaMikots on 06.07.2022.
//

import SwiftUI

struct Emoji: Decodable, Hashable {
    
    var id = UUID()
    var emoji: String
    
    init(emoji: String){
        self.emoji = emoji
    }
    
    private enum CodingKeys: String,
                             CodingKey {
        case emoji
    }
}
