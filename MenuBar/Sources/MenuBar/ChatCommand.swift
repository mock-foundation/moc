//
//  ChatCommand.swift
//  
//
//  Created by Егор Яковенко on 07.10.2022.
//

import SwiftUI
import Utilities
import L10n
import Backend

public struct ChatCommand: Commands {
    public init() { }
    
    @State private var archiveChatList = false
    @State private var titleString: String = L10nManager.shared.getString(by: "Menubar.Chats")
    
    public var body: some Commands {
        CommandMenu(titleString) {
            Toggle("Open archive chat list", isOn: $archiveChatList.didSet {
                sendUpdate(.toggle(.toggleArchive, $0))
            })
            .keyboardShortcut("A", modifiers: [.command, .option])
            .onReceive(TdApi.shared.client.updateSubject) { update in
                if case let .option(option) = update {
                    if option.name == "language_pack_id" {
                        Task {
                            self.titleString = L10nManager.shared.getString(by: "Menubar.Chats")
                        }
                    }
                }
            }
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
