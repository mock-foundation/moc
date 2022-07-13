#if os(macOS)
import AppKit
import IOKit
#elseif os(iOS)
import UIKit
import AVFoundation
#endif
import Foundation
import MacModels

public enum SystemUtils {
    private static let notificationQueue = DispatchQueue.main

    public static func post(notification: NSNotification.Name) {
        post(notification: notification, with: nil)
    }

    public static func post(notification: NSNotification.Name, with obj: Any?) {
        notificationQueue.async {
            NotificationCenter.default.post(name: notification, object: obj)
        }
    }

    public static func ncPublisher(for notification: NSNotification.Name) -> NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: notification)
    }

    // Thanks to https://stackoverflow.com/a/26845710
    public static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }

    #if os(macOS)
    // Thanks to https://www.reddit.com/r/swift/comments/gwf9fa/how_do_i_find_the_model_of_the_mac_in_swift/
    public static func getDeviceModel() async -> String {
        // Get device identifier
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        var modelIdentifier: String?

        if let modelData = IORegistryEntryCreateCFProperty(
            service,
            "model" as CFString,
            kCFAllocatorDefault,
            0
        ).takeRetainedValue() as? Data {
            if let modelIdentifierCString = String(data: modelData, encoding: .utf8)?.cString(using: .utf8) {
                modelIdentifier = String(cString: modelIdentifierCString)
            }
        }

        IOObjectRelease(service)
        if modelIdentifier == nil {
            return "Unknown"
        }

        // And then find a corresponding marketing name using the identifier
        // Force unwrap because it is guaranteed that it will not be nil
        let model = await MacModels.getDevice(by: modelIdentifier!)
        
        if let model = model {
            return model.name
        } else {
            return modelIdentifier!
        }
    }
    #elseif os(iOS)
    // Thanks https://www.zerotoappstore.com/how-to-get-iphone-device-model-swift.html
    public static func getDeviceModel() async -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        } ?? "Unknown"
    }
    #endif

    public static var osVersionString: String {
        let info = ProcessInfo().operatingSystemVersionString
        var systemVersionCodename: String {
            let version = ProcessInfo().operatingSystemVersion.majorVersion
            switch version {
                case 12:
                    return "macOS 12 Monterey"
                case 13:
                    return "macOS 13 Ventura"
            default:
                return "macOS \(version)"
            }
        }

        return "\(systemVersionCodename) \(info)"
    }

    public static func info<T>(key: String) -> T {
        Bundle.main.infoDictionary?[key]! as! T
    }

    public static func playAlertSound() {
        #if os(macOS)
        NSSound.beep()
        #elseif os(iOS)
        let systemSoundID: SystemSoundID = 1013
        AudioServicesPlaySystemSound(systemSoundID)
        #endif
    }
}
