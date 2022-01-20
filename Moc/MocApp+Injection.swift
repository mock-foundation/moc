//
//  MocApp.swift
//  Moc
//
//  Created by Егор Яковенко on 24.12.2021.
//

import SwiftUI
import TDLibKit
import Resolver
import SystemUtils
import Logging
import CryptoKit
import Generated
import Backend

final class TdLogger: TDLibKit.Logger {
    private let logger = Logging.Logger(label: "TDLib")

    func log(_ message: String, type: LoggerMessageType?) {
        queue.async {
            guard type != nil else {
                self.logger.info("TDLibKit: \(message)")
                return
            }

            var typeStr = ""
            switch type! {
                case .receive:
                    typeStr = "receive:"
                case .send:
                    typeStr = "send:"
                case .execute:
                    typeStr = "execute:"
                case .custom(let data):
                    typeStr = "\(data):"
            }

            #if DEBUG
            self.logger.info("TDLibKit: \(typeStr) \(message)")
            #endif
        }
    }

    let queue: DispatchQueue

    init() {
        queue = DispatchQueue(label: "TDLibKitLog", qos: .userInitiated)
    }
}

extension Resolver {
    private static let logger = Logging.Logger(label: "TDLibUpdates")

    public static func registerUI() {
        register { MainViewModel() }
    }

    // swiftlint:disable cyclomatic_complexity function_body_length
    public static func registerBackend() {
        register { TdChatDataSource() as ChatDataSource }
            .scope(.shared)
    }
}

// swiftlint:disable weak_delegate
@main
struct MocApp: App {
    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    private let logger = Logging.Logger(label: "TDLibUpdates")

    init() {
        Resolver.registerUI()
        Resolver.registerBackend()
        TdApi.shared.append(TdApi(client: TdClientImpl(completionQueue: .main, logger: TdLogger())))
        TdApi.shared[0].startTdLibUpdateHandler()
    }

    var body: some Scene {
        WindowGroup {
            ContentView<TdChatDataSource>()
        }

        Settings {
            TabView {
                GeneralPrefView()
                    .tabItem {
                        Label("General", systemImage: "gear")
                    }
                NotificationsAndSoundsPrefView()
                    .tabItem {
                        Label("Notifications and Sounds", systemImage: "bell")
                    }
                PrivacyView()
                    .tabItem {
                        Label("Privacy", systemImage: "lock")
                    }
                DataAndStoragePrefView()
                    .tabItem {
                        Label("Data and Storage", systemImage: "externaldrive")
                    }
                DevicesPrefView()
                    .tabItem {
                        Label("Devices", systemImage: "laptopcomputer.and.iphone")
                    }
                AppearancePrefView()
                    .tabItem {
                        Label("Appearance", systemImage: "paintbrush")
                    }
                LanguagePrefView()
                    .tabItem {
                        Label("Language", systemImage: "globe")
                    }
                StickersPrefView()
                    .tabItem {
                        Label("Stickers", systemImage: "rectangle.3.group.bubble.left")
                    }
                FoldersPrefView()
                    .tabItem {
                        Label("Folders", systemImage: "folder")
                    }
                AccountsPrefView()
                    .tabItem {
                        Label("Accounts", systemImage: "person.circle")
                    }
            }
            .frame(width: 800)
        }
    }
}
