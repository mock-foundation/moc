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
    #if os(macOS)
    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    #elseif os(iOS)
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    #endif

    init() {
        Resolver.registerUI()
        Resolver.registerBackend()
        TdApi.shared.append(TdApi(
            client: TdClientImpl(completionQueue: .global())
        ))
        TdApi.shared[0].startTdLibUpdateHandler()
        let newNavBarAppearance = UINavigationBarAppearance()
        newNavBarAppearance.configureWithDefaultBackground()
        
        let appearance = UINavigationBar.appearance()
        appearance.scrollEdgeAppearance = newNavBarAppearance
        appearance.compactAppearance = newNavBarAppearance
        appearance.standardAppearance = newNavBarAppearance
        appearance.compactScrollEdgeAppearance = newNavBarAppearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }.commands {
            AppCommands()
        }

        #if os(macOS)
        Settings {
            PreferencesContent()
        }
        #endif
    }
}
