//
//  AboutCommand.swift
//  Moc
//
//  Created by Егор Яковенко on 13.07.2022.
//

#if os(macOS)

import SwiftUI

public struct AboutCommand: Commands {
    @Environment(\.openWindow) private var openWindow
    
    public init() { }

    public var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button {
                openWindow(id: "about")
            } label: {
                Image(systemName: "info.circle")
                Text("About Moc")
            }
        }
    }
}

#endif
