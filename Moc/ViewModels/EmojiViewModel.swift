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
    
    enum EmojiCategory: String, CaseIterable, Identifiable {
        case 😀, 🐶, 🍏, 🏀, 🚗, 📺, 🧡, 🏳️
        
        var id: String { return self.rawValue }
        var stringValue: String {
            switch self {
            case .😀: return "smile"
            case .🐶: return "animal"
            case .🍏: return "food"
            case .🏀: return "activities"
            case .🚗: return "transport"
            case .📺: return "objects"
            case .🧡: return "symbols"
            case .🏳️: return "flags"
            }
        }
    }
    
    @Published private(set) var didFetchingEmoji = false
    @Published private(set) var emoji: [SubCategory] = []
    @Published private(set) var favoriteEmoji: [SubCategory] = []
    
    private let emojiService: EmojiServiceable
    
    public init(emojiService: EmojiServiceable) {
        self.emojiService = emojiService
    }
    
    @MainActor
    func getEmojiFromCategory(emojiName: String) async {
        Task {
            let result = try await emojiService.getEmoji(emojiName, "50")
            self.emoji = result.subCategories
            print(result)
            didFetchingEmoji = true
        }
    }
    
    
    @MainActor
    func getEmoji(){
        Task {
            if self.emojiSearch.isEmpty{
                self.emoji = self.favoriteEmoji
            } else {
                do {
                    let result = try await emojiService.getEmoji(self.emojiSearch, "50")
                    self.emoji = result.subCategories
                    print(result)
                    didFetchingEmoji = true
                } catch {
                    print("some error in getEmoji")
                }
            }
        }
    }
    @MainActor
    func getFavoriteEmoji() async  {
        Task {
            if let result = try await emojiService.getFavorite() {
                self.favoriteEmoji = result.subCategories
                self.emoji = favoriteEmoji
                print(result)
            } else {
                print("some error in getFavorite")
            }
        }
    }
}
