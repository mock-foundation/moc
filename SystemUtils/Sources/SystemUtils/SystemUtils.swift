import Foundation
import IOKit
import AppKit
import CommonCrypto

//  Thanks to https://betterprogramming.pub/5-swift-extensions-to-generate-randoms-87401ccc60f
extension Character {
    static func returnQ(inq: Range<Int>) -> Int {
        var generator = SystemRandomNumberGenerator()
        return Int.random(in: inq, using: &generator)
    }

    // swiftlint:disable identifier_name
    static func randomCharacter() -> Character {
        let digits = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        let c = returnQ(inq: 0..<digits.count)
        let r = digits.index(digits.startIndex, offsetBy: c)
        let d = String(digits[r])
        return Character(d)
    }
}

public struct SystemUtils {
    private static let notificationQueue = DispatchQueue.main

    public static func post(notification: NSNotification.Name) {
        notificationQueue.async {
            NotificationCenter.default.post(name: notification, object: nil)
        }
    }

    public static func post(notification: NSNotification.Name, withObject obj: Any?) {
        notificationQueue.async {
            NotificationCenter.default.post(name: notification, object: obj)
        }
    }

    // Thanks to https://stackoverflow.com/a/26845710
    public static func randomString(length: Int) -> String {
        return String((0..<length).map { _ in
            Character.randomCharacter()
        })
    }

    // Thanks to https://stackoverflow.com/a/25391020
    public static func sha256(data: Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }

    // Thanks to https://www.reddit.com/r/swift/comments/gwf9fa/how_do_i_find_the_model_of_the_mac_in_swift/
    public static var macModel: String {
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
        let serverInfoBundle = Bundle(path: "/System/Library/PrivateFrameworks/ServerInformation.framework/")
        let sysInfoFile = serverInfoBundle?.url(forResource: "SIMachineAttributes", withExtension: "plist")
        let plist = NSDictionary(contentsOfFile: sysInfoFile!.path)

        let modelDict = plist![modelIdentifier!] as? NSDictionary

        if modelDict == nil {
            return modelIdentifier!
        }

        let modelInfo = modelDict!["_LOCALIZABLE"] as? NSDictionary

        if modelInfo == nil {
            return modelIdentifier!
        }

        let model = modelInfo!["marketingModel"] as? String

        if model == nil {
            return modelIdentifier!
        }

        return model!
    }

    public static var osVersionString: String {
        let info = ProcessInfo().operatingSystemVersionString
        var systemVersionCodename: String {
            let version = ProcessInfo().operatingSystemVersion.majorVersion
            switch version {
                case 11:
                    return "macOS 11 Big Sur"
                case 12:
                    return "macOS 12 Monterey"
                default:
                    return "macOS \(version)"
            }
        }

        return "\(systemVersionCodename) \(info)"
    }

    public static func info<T>(key: String) -> T? {
        return Bundle.main.infoDictionary?[key] as? T
    }

    public static func playAlertSound() {
        NSSound.beep()
    }
}
