//
//  AppCommands.swift
//  Moc
//
//  Created by Егор Яковенко on 11.02.2022.
//

import SwiftUI
import AppCenterAnalytics
import Defaults
import Utilities

struct AppCommands: Commands {
    #if os(macOS)
    @ObservedObject var updateManager: UpdateManager
    #endif
    
    @Default(.chatShortcuts) private var chatShortcuts

    var body: some Commands {
        #if os(macOS)
        CommandGroup(after: .appInfo) {
            Button(action: updateManager.checkForUpdates) {
                Image(systemName: updateManager.canCheckForUpdates
                      ? "arrow.triangle.2.circlepath"
                      : "exclamationmark.arrow.triangle.2.circlepath")
                Text("Check for updates...")
            }.disabled(!updateManager.canCheckForUpdates)
        }
        #endif
        CommandGroup(after: .appSettings) {
            Button {

            } label: {
                Image(systemName: "bookmark")
                Text("Saved messages")
            }.keyboardShortcut("0")
            Divider()
            Group {
                if chatShortcuts.isEmpty {
                    Text("No chat shortcuts")
                } else {
                    ForEach(chatShortcuts, id: \.self) { chatId in
                        Button {
                            SystemUtils.post(notification: .openChatWithId, with: chatId)
                        } label: {
                            CompactChatItemView(chatId: chatId)
                        }
                    }
                }
            }
            Divider()
            Button(action: {
                Analytics.trackEvent("Opened \"Telegram Tips\" channel from the menubar")
            }, label: {
                Image(systemName: "text.book.closed")
                Text("Telegram Tips")
            })
            Button(action: {
                Analytics.trackEvent("Opened \"Moc Updates\" channel from the menubar")
            }, label: {
                Image(systemName: "newspaper")
                Text("Moc Updates")
            })
            Divider()
        }
    }
}
