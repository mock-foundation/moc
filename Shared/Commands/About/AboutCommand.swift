//
//  AboutCommand.swift
//  Moc
//
//  Created by Егор Яковенко on 13.07.2022.
//

#if os(macOS)

import SwiftUI

struct BackportedAboutCommand: Commands {
    @Environment(\.openURL) private var openURL
    
    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button {
                openURL(URL(string: "moc://internal/openAbout")!)
            } label: {
                Image(systemName: "info.circle.fill")
                Text("About Moc")
            }
        }
    }
}

@available(macOS 13, *)
struct AboutCommand: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button {
                openWindow(id: "about")
            } label: {
                Text("About Moc")
            }
        }
    }
}

#endif
