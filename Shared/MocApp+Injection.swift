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

@main
struct MocApp: App {
    @Environment(\.scenePhase) var scenePhase
    #if os(macOS)
    @StateObject var updateManager = UpdateManager()
    #endif
    
    init() {
        Resolver.registerUI()
        Resolver.registerBackend()
        TdApi.shared.append(TdApi(
            client: TdClientImpl(completionQueue: .global())
        ))
        TdApi.shared[0].startTdLibUpdateHandler()
        
        Task {
            AppCenter.countryCode = try await TdApi.shared[0].getCountryCode().text
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
            }.handlesExternalEvents(matching: Set(arrayLiteral: "internal/openAbout"))
        }
    }
    #endif
    
    var aboutCommand: some Commands {
        if #available(macOS 13.0, *) {
            return AboutCommand()
        } else {
            return BackportedAboutCommand()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { phase in
            Task {
                try await TdApi.shared[0].setOption(
                    name: .online,
                    value: .boolean(.init(value: phase == .active)))
            }
        }
        .commands {
            aboutCommand
            #if os(macOS)
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
