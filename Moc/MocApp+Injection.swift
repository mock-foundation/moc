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

final class TdLogger: Logger {
    func log(_ message: String, type: LoggerMessageType?) {
        queue.async {
            guard type != nil else {
                NSLog("TDLibKit: \(message)")
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

            NSLog("TDLibKit: \(typeStr) \(message)")
        }
    }

    let queue: DispatchQueue

    init() {
        queue = DispatchQueue(label: "TDLibKitLog", qos: .userInitiated)
    }
}

extension Resolver {
    public static func registerUI() {
        register { MainViewModel() }
    }

    // swiftlint:disable cyclomatic_complexity function_body_length
    public static func registerTd() {
        let tdApi = TdApi(client: TdClientImpl(completionQueue: .main, logger: TdLogger()))
        tdApi.client.run {
            do {
                let update = try tdApi.decoder.decode(Update.self, from: $0)
                switch update {
                        // MARK: - Authorization state
                    case .updateAuthorizationState(let state):
                        switch state.authorizationState {
                            case .authorizationStateWaitTdlibParameters:
                                SystemUtils.post(notification: .authorizationStateWaitTdlibParameters)
                                Task {
                                    try? await tdApi.setTdlibParameters(parameters: TdlibParameters(
                                        apiHash: MocApp.apiHash,
                                        apiId: Int(MocApp.apiKey)!,
                                        applicationVersion: (
                                            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                                        ) ?? "Unknown",
                                        databaseDirectory: "",
                                        deviceModel: SystemUtils.macModel,
                                        enableStorageOptimizer: true,
                                        filesDirectory: "",
                                        ignoreFileNames: false,
                                        systemLanguageCode: "en-US",
                                        systemVersion: SystemUtils.osVersionString,
                                        useChatInfoDatabase: true,
                                        useFileDatabase: true,
                                        useMessageDatabase: true,
                                        useSecretChats: false,
                                        useTestDc: false
                                    ))
                                }
                            case .authorizationStateWaitEncryptionKey(let info):
                                SystemUtils.post(notification: .authorizationStateWaitEncryptionKey, withObject: info)
                                Task {
                                    try? await tdApi.checkDatabaseEncryptionKey(encryptionKey: nil)
                                }
                            case .authorizationStateWaitPhoneNumber:
                                SystemUtils.post(notification: .authorizationStateWaitPhoneNumber)
                            case .authorizationStateWaitCode(let info):
                                SystemUtils.post(notification: .authorizationStateWaitCode, withObject: info)
                            case .authorizationStateWaitRegistration(let info):
                                SystemUtils.post(notification: .authorizationStateWaitRegistration, withObject: info)
                            case .authorizationStateWaitPassword(let info):
                                SystemUtils.post(notification: .authorizationStateWaitPassword, withObject: info)
                            case .authorizationStateReady:
                                SystemUtils.post(notification: .authorizationStateReady)
                            case .authorizationStateWaitOtherDeviceConfirmation(let info):
                                SystemUtils.post(
                                    notification: .authorizationStateWaitOtherDeviceConfirmation,
                                    withObject: info
                                )
                            case .authorizationStateLoggingOut:
                                SystemUtils.post(notification: .authorizationStateLoggingOut)
                            case .authorizationStateClosing:
                                SystemUtils.post(notification: .authorizationStateClosing)
                            case .authorizationStateClosed:
                                SystemUtils.post(notification: .authorizationStateClosed)
                        }
                        // MARK: - Chat position
                    case .updateChatPosition(let state):
                        SystemUtils.post(notification: .updateChatPosition, withObject: state)
                    case .updateNewMessage(let state):
                        SystemUtils.post(notification: .updateNewMessage, withObject: state)
                    case .updateChatLastMessage(let state):
                        SystemUtils.post(notification: .updateChatLastMessage, withObject: state)
                    case .updateNewChat(let state):
                        SystemUtils.post(notification: .updateNewChat, withObject: state)
                    case .updateFile(let info):
                        SystemUtils.post(notification: .updateFile, withObject: info)
                    default:
                        NSLog("Unhandled TDLib update \(update)")
                }
            } catch {
                NSLog("Error in TDLib update handler \(error.localizedDescription)")
            }
        }
        register { tdApi }
    }
}

@main
struct MocApp: App {
    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate

    init() {
        Resolver.registerUI()
        Resolver.registerTd()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
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
