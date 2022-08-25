//
//  EmojiViewModel.swift
//  Moc
//
//  Created by DariaMikots on 06.07.2022.
//

import SwiftUI
import Networking

class EmojiViewModel: ObservableObject {
    
    @Published var emojiSearch: String = "" {
        didSet {
            getEmoji()
        }
    }
    
    @Published private(set) var didFetchingEmoji = false
    @Published private(set) var emoji: Emoji?
    
    private let emojiService: EmojiServiceable
    
    public init(emojiService: EmojiServiceable) {
        self.emojiService = emojiService
    }
    
    func getEmoji() {
        Task {
            let searchText = self.emojiSearch.isEmpty ? "smile" : self.emojiSearch
            do {
                let result = try await emojiService.getEmoji(searchText, "100")
                self.emoji = result
                didFetchingEmoji = true
            } catch {
                print("some error in getEmoji")
            }
        }
    }
}
