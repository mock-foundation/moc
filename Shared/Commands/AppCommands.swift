//
//  AppCommands.swift
//  Moc
//
//  Created by Егор Яковенко on 11.02.2022.
//

import SwiftUI

struct AppCommands: Commands {
    @ObservedObject var updateManager: UpdateManager

    var body: some Commands {
        #if !Homebrew
        CommandGroup(after: .appInfo) {
            Button("Check for updates...", action: updateManager.checkForUpdates)
                .disabled(!updateManager.canCheckForUpdates)
        }
        #endif
        CommandGroup(after: .appSettings) {
            Button(action: {
                
            }, label: {
                Image(systemName: "bookmark")
                Text("Saved messages")
            }).keyboardShortcut("0")
            Button(action: {

            }, label: {
                Image(systemName: "person.wave.2")
                Text("Find people nearby")
            })
            Divider()
            Button(action: {

            }, label: {
                Image(systemName: "text.book.closed")
                Text("Telegram Tips")
            })
            Button(action: {

            }, label: {
                Image(systemName: "newspaper")
                Text("Moc Updates")
            })
            Divider()
        }
    }
}
