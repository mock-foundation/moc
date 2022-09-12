//
//  WhatsNew.swift
//  Moc
//
//  Created by Егор Яковенко on 12.09.2022.
//

import Foundation
import WhatsNewKit

let whatsNewCollection: WhatsNewCollection = [
    WhatsNew(
        version: "0.2.0",
        title: "What's New in Moc",
        features: [
            .init(
                image: .init(
                    systemName: "rectangle.3.group.fill",
                    foregroundColor: .green),
                title: "Photos, videos, and files",
                subtitle: "See and send media files, like you do in official clients!"),
            .init(
                image: .init(
                    systemName: "folder",
                    foregroundColor: .cyan),
                title: "Folders",
                subtitle: "Group chats with easy-to-use folders, accessible on the top or the side of the chat list"),
            .init(
                image: .init(
                    systemName: "text.and.command.macwindow",
                    foregroundColor: .orange),
                title: "Chat Shortcuts",
                subtitle: "Add chats to Chat Shortcuts, and easily access them by using the menubar or even by pressing 􀆔 and the chat index!"),
            .init(
                image: .init(
                    systemName: "laptopcomputer.and.ipad",
                    foregroundColor: .gray),
                title: "Support for iPadOS (experimental)",
                subtitle: "With support for iPadOS, you can now enjoy Moc on the go!"),
            .init(
                image: .init(
                    systemName: "text.bubble",
                    foregroundColor: .indigo),
                title: "Message style formatting",
                subtitle: "Moc can now apply styling to text, like bold, italic, or even links!")
        ],
        primaryAction: .init(
            title: "Get started",
            backgroundColor: .blue,
            foregroundColor: .white),
        secondaryAction: .init(
            title: "More info on GitHub",
            foregroundColor: .blue,
            action: .openURL(URL(string: "https://github.com/mock-foundation/moc/releases/tag/0.2.0"))))
]

var whatsNewStore: WhatsNewVersionStore {
    #if DEBUG
    InMemoryWhatsNewVersionStore()
    #else
    UserDefaultsWhatsNewVersionStore()
    #endif
}
