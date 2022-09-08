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
import TDLibKit

struct AppCommands: Commands {
    #if os(macOS)
    @ObservedObject var updateManager: UpdateManager
    #endif
    
    @Default(.chatShortcuts) private var chatShortcuts
    @Default(.useSavedMessagesShortcut) private var useSavedMessagesShortcut

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
                Task {
                    let me = try await TdApi.shared.getMe()
                    SystemUtils.post(notification: .openChatWithId, with: me.id)
                }
            } label: {
                Image(systemName: "bookmark")
                Text("Saved messages")
            }.if(useSavedMessagesShortcut) {
                $0.keyboardShortcut("0")
            }
            Divider()
            Group {
                if chatShortcuts.isEmpty {
                    Text("No chat shortcuts")
                } else {
                    ForEach(Array(chatShortcuts.enumerated()), id: \.element) { index, chatId in
                        Button {
                            SystemUtils.post(notification: .openChatWithId, with: chatId)
                        } label: {
                            CompactChatItemView(chatId: chatId)
                        }
                        .if(index + (useSavedMessagesShortcut ? 1 : 0) <= 9) {
                            $0.keyboardShortcut(.init(Character("\(index + (useSavedMessagesShortcut ? 1 : 0))")))
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
