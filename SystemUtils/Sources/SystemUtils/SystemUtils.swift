import Foundation
import IOKit

public struct SystemUtils {
    public static func post(notification: NSNotification.Name) {
        NotificationCenter.default.post(name: notification, object: nil)
    }

    public static func post(notification: NSNotification.Name, withObject obj: Any?) {
        NotificationCenter.default.post(name: notification, object: obj)
    }

    // Thanks to https://www.reddit.com/r/swift/comments/gwf9fa/how_do_i_find_the_model_of_the_mac_in_swift/
    public static func getMacModel() -> String {
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

    public static func getOSVersionString() -> String {
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
}