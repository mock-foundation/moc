//
//  TdService.swift
//  Moc
//
//  Created by Егор Яковенко on 30.12.2021.
//

import TDLibKit
import Resolver
import Foundation

/// Runs everything needed for TDLib to run, and contains a global update handler.
/// Usually the update handler just posts a notification to the default NotificationCenter about an update, but
/// sometimes it can handle the update **and** post a notification about it.
class TdService {
    @Injected private var tdApi: TdApi
    @Injected private var mainViewModel: MainViewModel

    public func initHandler() {
        tdApi.client.run {
            do {
                let update = try self.tdApi.decoder.decode(Update.self, from: $0)
                switch update {
                        // MARK: - Authorization state
                    case .updateAuthorizationState(let state):
                        switch state.authorizationState {
                            case .authorizationStateWaitTdlibParameters:
                                self.post(notification: .authorizationStateWaitTdlibParameters)
                                Task(priority: .medium) {
                                    let _ = try! await self.tdApi.setTdlibParameters(parameters: TdlibParameters(
                                        apiHash: Bundle.main.infoDictionary?["TdApiHash"] as! String,
                                        apiId: Bundle.main.infoDictionary?["TdApiId"] as! Int,
                                        applicationVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String,
                                        databaseDirectory: "",
                                        deviceModel: self.getMacModel() ?? "Unknown",
                                        enableStorageOptimizer: true,
                                        filesDirectory: "",
                                        ignoreFileNames: false,
                                        systemLanguageCode: "en-US",
                                        systemVersion: self.getOSVersionString(),
                                        useChatInfoDatabase: true,
                                        useFileDatabase: true,
                                        useMessageDatabase: true,
                                        useSecretChats: false,
                                        useTestDc: true
                                    ))
                                }
                            case .authorizationStateWaitEncryptionKey(_):
                                self.post(notification: .authorizationStateWaitEncryptionKey)
                                Task(priority: .medium) {
                                    try! await self.tdApi.checkDatabaseEncryptionKey(encryptionKey: nil)
                                }
                            case .authorizationStateWaitPhoneNumber:
                                self.post(notification: .authorizationStateWaitPhoneNumber)
                            case .authorizationStateWaitCode(let info):
                                self.post(notification: .authorizationStateWaitCode, withObject: info)
                            case .authorizationStateWaitRegistration(let info):
                                self.post(notification: .authorizationStateWaitRegistration, withObject: info)
                            case .authorizationStateWaitPassword(let info):
                                self.post(notification: .authorizationStateWaitPassword, withObject: info)
                            case .authorizationStateReady:
                                self.post(notification: .authorizationStateReady)
                            case .authorizationStateWaitOtherDeviceConfirmation(let info):
                                self.post(notification: .authorizationStateWaitOtherDeviceConfirmation, withObject: info)
                            case .authorizationStateLoggingOut:
                                self.post(notification: .authorizationStateLoggingOut)
                            case .authorizationStateClosing:
                                self.post(notification: .authorizationStateClosing)
                            case .authorizationStateClosed:
                                self.post(notification: .authorizationStateClosed)
                        }
                        // MARK: - Chat position
                    case .updateChatPosition(let state):
                        self.post(notification: .updateChatPosition, withObject: state)
                    default:
                        NSLog("Unhandled TDLib update \(update)")
                }
            } catch {
                NSLog("Error in TDLib update handler \(error.localizedDescription)")
            }
        }

    }

    private func post(notification: NSNotification.Name) {
        NotificationCenter.default.post(name: notification, object: nil)
    }

    private func post(notification: NSNotification.Name, withObject obj: Any?) {
        NotificationCenter.default.post(name: notification, object: obj)
    }

    // Thanks to https://www.reddit.com/r/swift/comments/gwf9fa/how_do_i_find_the_model_of_the_mac_in_swift/
    func getMacModel() -> String? {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        var modelIdentifier: String?

        if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
            if let modelIdentifierCString = String(data: modelData, encoding: .utf8)?.cString(using: .utf8) {
                modelIdentifier = String(cString: modelIdentifierCString)
            }
        }

        IOObjectRelease(service)
        return modelIdentifier
    }

    func getOSVersionString() -> String {
        let info = ProcessInfo().operatingSystemVersionString
        NSLog(info)
        return info
    }
}
