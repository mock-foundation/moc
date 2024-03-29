//
//  MocApp.swift
//  Moc
//
//  Created by Егор Яковенко on 24.12.2021.
//

import AppCenter
import AppCenterCrashes
import Backend
import CryptoKit
import Resolver
import SwiftUI
import Utilities
import Logs
import WhatsNewKit
import MenuBar
import L10n

public extension Resolver {
    static func registerServices() {
        register { TdChatService() as (any ChatService) }
            .scope(.shared)
        register { TdChatInspectorService() as (any ChatInspectorService) }
            .scope(.shared)
        register { TdLoginService() as (any LoginService) }
            .scope(.shared)
        register { TdAccountsPrefService() as (any AccountsPrefService) }
            .scope(.shared)
        register { TdFoldersPrefService() as (any FoldersPrefService) }
            .scope(.shared)
        register { TdMainService() as (any MainService) }
            .scope(.shared)
    }
}

@main
struct MocApp: App {
    @Environment(\.scenePhase) var scenePhase
    #if os(macOS)
    @StateObject var updateManager = UpdateManager()
    #endif
    
    init() {
        Resolver.registerServices()
        TdApi.shared.startTdLibUpdateHandler()
        
        Task {
            // Just accessing L10nManager.shared, so it will init
            _ = L10nManager.shared.languagePackID.isEmpty
            
            AppCenter.countryCode = try await TdApi.shared.getCountryCode().text
        }
        
        AppCenter.start(withAppSecret: Secret.appCenterSecret, services: [Crashes.self])
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.whatsNew, WhatsNewEnvironment(
                    versionStore: whatsNewStore,
                    whatsNewCollection: whatsNewCollection
                ))
        }
        .onChange(of: scenePhase) { phase in
            Task {
                try await TdApi.shared.setOption(
                    name: .online,
                    value: .boolean(.init(value: phase == .active)))
            }
        }
        .commands {
            #if os(macOS)
            AboutCommand()
            AppCommands(updateManager: updateManager)
            #else
            AppCommands()
            #endif
            ChatCommand()
            FileCommand()
        }
        
        #if os(macOS)
        WindowGroup(id: "about") {
            AboutView()
                .background(VisualEffectView(material: .popover).ignoresSafeArea())
        }
        .defaultPosition(.top)
        .defaultSize(width: 500, height: 300)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        
        Settings {
            SettingsContent()
        }
        #endif
    }
}
