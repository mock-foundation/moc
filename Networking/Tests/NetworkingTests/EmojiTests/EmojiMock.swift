//
//  File.swift
//  
//
//  Created by DariaMikots on 08.07.2022.
//

import Foundation
import Networking

final class EmojiServiceMock: Mockable, EmojiServiceable {
    func getEmoji(_ name: String, _ length: String) async throws -> Emoji {
        return loadJSON(filename: "emoji", type: Emoji.self)
    }
}
