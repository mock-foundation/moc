//
//  AppCommands.swift
//  Moc
//
//  Created by Егор Яковенко on 11.02.2022.
//

import SwiftUI

struct AppCommands: Commands {
    #if os(macOS)
    @ObservedObject var updateManager: UpdateManager
    #endif

    var body: some Commands {
        #if os(macOS)
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
