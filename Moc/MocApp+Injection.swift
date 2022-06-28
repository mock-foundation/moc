//
//  MocApp.swift
//  Moc
//
//  Created by Егор Яковенко on 24.12.2021.
//

import Backend
import CryptoKit
import Resolver
import SwiftUI
import Utilities
import TDLibKit
import Logs

public extension Resolver {
    static func registerUI() {
        register { MainViewModel() }.scope(.shared)
        register { ChatViewModel() }.scope(.shared)
    }

    static func registerBackend() {
        register { TdChatService() as ChatService }
            .scope(.shared)
        register { TdLoginService() as LoginService }
            .scope(.shared)
        register { TdAccountsPrefService() as AccountsPrefService }
            .scope(.shared)
        register { TdFoldersPrefService() as FoldersPrefService }
            .scope(.shared)
        register { TdMainService() as MainService }
            .scope(.shared)
    }
}

// swiftlint:disable weak_delegate
@main
struct MocApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        Resolver.registerUI()
        Resolver.registerBackend()
        TdApi.shared.append(TdApi(
            client: TdClientImpl(completionQueue: .global())
        ))
        TdApi.shared[0].startTdLibUpdateHandler()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            AppCommands()
        }
        .onChange(of: scenePhase) { phase in
            Task {
                try await TdApi.shared[0].setOption(
                    name: "online",
                    value: .optionValueBoolean(.init(value: phase == .active)))
            }
        }

        #if os(macOS)
        Settings {
            SettingsContent()
        }
        #endif
    }
}
