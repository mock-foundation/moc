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
                sendUpdate(.trigger(.toggleChatInspector))
            }.keyboardShortcut("I")
            Button("Toggle chat info") {
                sendUpdate(.trigger(.toggleChatInfo))
            }.keyboardShortcut("I", modifiers: [.command, .shift])
        }
    }
}
