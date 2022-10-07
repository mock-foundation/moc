//
//  ChatCommand.swift
//  
//
//  Created by Егор Яковенко on 07.10.2022.
//

import SwiftUI
import Utilities

public struct ChatCommand: Commands {
    public init() { }
    
    public var body: some Commands {
        CommandMenu("Chat") {
            Button("Toggle chat inspector") {
                SystemUtils.post(notification: .chatInspectorToggle)
            }.keyboardShortcut("I", modifiers: .command)
            Button("Open chat info") {
                SystemUtils.post(notification: .toggleChatInfo)
            }.keyboardShortcut("I", modifiers: [.command, .shift])
        }
    }
}
