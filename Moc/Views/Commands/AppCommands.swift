//
//  AppCommands.swift
//  Moc
//
//  Created by Егор Яковенко on 11.02.2022.
//

import SwiftUI

struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(after: CommandGroupPlacement.appSettings) {
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
