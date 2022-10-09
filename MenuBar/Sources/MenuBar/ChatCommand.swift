//
//  ChatCommand.swift
//  
//
//  Created by Егор Яковенко on 07.10.2022.
//

import SwiftUI
import Utilities

public struct ChatCommand: Commands {
    var menubarUpdater: MenubarUpdater
    
    public init(menubarUpdater: MenubarUpdater) {
        self.menubarUpdater = menubarUpdater
    }
    
    public var body: some Commands {
        CommandMenu("Chat") {
            Button("Toggle chat inspector") {
                menubarUpdater.subject.send(.trigger(.toggleChatInspector))
            }.keyboardShortcut("I", modifiers: .command)
            Button("Open chat info") {
                menubarUpdater.subject.send(.trigger(.toggleChatInfo))
            }.keyboardShortcut("I", modifiers: [.command, .shift])
        }
    }
}
