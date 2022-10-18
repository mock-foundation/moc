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
    
    @State private var archiveChatList = false
    
    public var body: some Commands {
        CommandMenu("Chats") {
            Toggle("Open archive chat list", isOn: $archiveChatList.didSet {
                sendUpdate(.toggle(.toggleArchive, $0))
            })
            .keyboardShortcut("A", modifiers: [.command, .option])
            Divider()
            Button("Toggle chat inspector") {
                sendUpdate(.trigger(.toggleChatInspector))
            }.keyboardShortcut("I", modifiers: .command)
            Button("Toggle chat info") {
                sendUpdate(.trigger(.toggleChatInfo))
            }.keyboardShortcut("I", modifiers: [.command, .shift])
            
        }
    }
}
