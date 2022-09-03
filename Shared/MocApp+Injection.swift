//
//  MocApp.swift
//  Moc
//
//  Created by Егор Яковенко on 24.12.2021.
//

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import Backend
import CryptoKit
import Resolver
import SwiftUI
import Utilities
import Logs

public extension Resolver {
    static func registerBackend() {
        register { TdChatService() as (any ChatService) }
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
        Resolver.registerBackend()
        TdApi.shared.startTdLibUpdateHandler()
        
        Task {
            AppCenter.countryCode = try await TdApi.shared.getCountryCode().text
        }
        
        AppCenter.start(withAppSecret: Secret.appCenterSecret, services: [
            Analytics.self,
            Crashes.self
        ])
        Analytics.enabled = true
    }
    
    #if os(macOS)
    var aboutWindow: some Scene {
        if #available(macOS 13, *) {
            return WindowGroup(id: "about") {
                AboutView()
                    .background(VisualEffectView(material: .popover).ignoresSafeArea())
            }
            .defaultPosition(.top)
            .defaultSize(width: 500, height: 300)
            .windowResizability(.contentSize)
            .windowStyle(.hiddenTitleBar)
        } else {
            return WindowGroup(id: "about") {
                AboutView()
                    .onOpenURL { url in
                        print(url)
                    }
            }
            .handlesExternalEvents(matching: Set(arrayLiteral: "internal/openAbout"))
        }
    }
    
    var aboutCommand: some Commands {
        if #available(macOS 13.0, iOS 16, *) {
            return AboutCommand()
        } else {
            return BackportedAboutCommand()
        }
    }
    #endif
    
    var body: some Scene {
        WindowGroup {
            RootView()
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
            aboutCommand
            AppCommands(updateManager: updateManager)
            #else
            AppCommands()
            #endif
        }
        
        #if os(macOS)
        aboutWindow
        
        Settings {
            SettingsContent()
        }
        #endif
    }
}
