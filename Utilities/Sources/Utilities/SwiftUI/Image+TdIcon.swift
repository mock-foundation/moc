//
//  Image+TdIcon.swift
//  
//
//  Created by Егор Яковенко on 26.05.2022.
//

import SwiftUI

public extension Image {
    // swiftlint:disable cyclomatic_complexity
    init(tdIcon icon: String) {
        switch icon {
            case "All": self.init(systemName: "bubble.left.and.bubble.right")
            case "Unread": self.init(systemName: "exclamationmark.bubble")
            case "Unmuted": self.init(systemName: "text.bubble")
            case "Bots": self.init(systemName: "pc")
            case "Channels": self.init(systemName: "megaphone")
            case "Groups": self.init(systemName: "person.2")
            case "Private": self.init(systemName: "person")
            case "Setup": self.init(systemName: "list.bullet")
            case "Cat": self.init(systemName: "pawprint")
            case "Crown": self.init(systemName: "crown")
            case "Favorite": self.init(systemName: "star")
            case "Flower": self.init(systemName: "leaf")
            case "Game": self.init(systemName: "gamecontroller")
            case "Home": self.init(systemName: "house")
            case "Love": self.init(systemName: "heart")
            case "Mask": self.init(systemName: "theatermasks")
            case "Party": self.init(systemName: "sparkles")
            case "Sport": self.init(systemName: "sportscourt")
            case "Study": self.init(systemName: "graduationcap")
            case "Trade": self.init(systemName: "cart")
            case "Travel": self.init(systemName: "paperplane")
            case "Work": self.init(systemName: "building.2")
            default: self.init(systemName: "folder")
        }
    }
}
