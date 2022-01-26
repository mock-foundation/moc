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
    let queue: DispatchQueue

    func log(_ message: String, type: LoggerMessageType?) {
        queue.async {
            guard type != nil else {
                self.logger.info("\(message)")
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
            self.logger.info("\(typeStr) \(message)")
            #endif
        }
    }

    init() {
        queue = DispatchQueue(label: "TDLibKitLog", qos: .userInitiated)
    }
}

extension Resolver {
    private static let logger = Logging.Logger(label: "TDLibUpdates")

    public static func registerUI() {
        register { MainViewModel() }.scope(.shared)
        register { ChatViewModel() }.scope(.shared)
    }

    public static func registerBackend() {
        register { TdChatService() as ChatService }
            .scope(.shared)
        register { TdLoginService() as LoginService }
            .scope(.shared)
        register { TdAccountsPrefService() as AccountsPrefService }
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
        TdApi.shared.append(TdApi(
            client: TdClientImpl(
                completionQueue: DispatchQueue(
                    label: tdCompletionQueueLabel,
                    qos: .userInteractive
                ),
                logger: TdLogger()
            )
        ))
        TdApi.shared[0].startTdLibUpdateHandler()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        Settings {
            PreferencesContent()
        }
    }
}
