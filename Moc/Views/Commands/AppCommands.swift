//
//  AppCommands.swift
//  Moc
//
//  Created by Егор Яковенко on 11.02.2022.
//

import SwiftUI
import SPSafeSymbols

struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(after: CommandGroupPlacement.appSettings) {
            Button(action: {

            }, label: {
                Image(.bookmark)
                Text("Saved messages")
            }).keyboardShortcut("0")
            Button(action: {

            }, label: {
                Image(.person.wave_2)
                Text("Find people nearby")
            })
            Divider()
            Button(action: {

            }, label: {
                Image(.text.bookClosed)
                Text("Telegram Tips")
            })
            Button(action: {

            }, label: {
                Image(.newspaper)
                Text("Moc Updates")
            })
            Divider()
        }
    }
}
