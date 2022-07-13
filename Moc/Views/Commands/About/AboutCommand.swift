//
//  AboutCommand.swift
//  Moc
//
//  Created by Егор Яковенко on 13.07.2022.
//

#if os(macOS)

import SwiftUI

@available(macOS 13.0, *)
struct AboutCommand: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button {
                openWindow(id: "about")
            } label: {
                Text("About Moc...")
            }
        }
    }
}

#endif
