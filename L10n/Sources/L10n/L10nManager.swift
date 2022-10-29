//
//  L10nManager.swift
//  
//
//  Created by Егор Яковенко on 19.10.2022.
//

import L10n_swift
import TDLibKit
import Backend
import Combine

public struct L10nManager {
    public static let shared = L10nManager()
    private let tdApi = TdApi.shared
    private var subscribers: [AnyCancellable] = []
    private var languagePackID = "en"
    
    public func getString(
        by key: String,
        source: LocalizationSource = .automatic,
        arg: Any? = nil
    ) async throws -> String {
        switch source {
            case .strings:
                return getLocalizableString(by: key)
            case .telegram:
                return try await getTelegramString(by: key, arg: arg)
            case .automatic:
                let localizable = getLocalizableString(by: key)
                if localizable == key { // If not found
                    return try await getTelegramString(by: key, arg: arg)
                } else {
                    return localizable
                }
        }
    }
    
    func getLocalizableString(by key: String) -> String {
        print("WARNING: getLocalizableString(by:) is not implemented")
        return key
    }
    
    // swiftlint:disable cyclomatic_complexity
    func getTelegramString(
        by key: String,
        from languagePackID: String? = nil,
        arg: Any? = nil
    ) async throws -> String {
        guard let langString = try await tdApi.getLanguagePackStrings(
            keys: [key],
            languagePackId: languagePackID ?? self.languagePackID
        ).strings.first else {
            return key
        }
        
        guard let stringValue = langString.value else { return key }
        
        switch stringValue {
            case let .ordinary(ordinary):
                return String(format: ordinary.value, arg as! CVarArg)
            case let .pluralized(pluralized):
                if let arg {
                    guard let intArg = arg as? Int else { return pluralized.otherValue }
                    let lastDigit = intArg % 10
                    
                    print(pluralized)
                    
                    func format(for value: String) -> String {
                        if value == "" {
                            return String(format: pluralized.otherValue, arg as! CVarArg)
                        } else {
                            return String(format: value, arg as! CVarArg)
                        }
                    }
                    
                    switch lastDigit {
                        case 0: return format(for: pluralized.zeroValue)
                        case 1: return format(for: pluralized.oneValue)
                        case 2: return format(for: pluralized.twoValue)
                        case 2...4: return format(for: pluralized.fewValue)
                        case 4...9: return format(for: pluralized.manyValue)
                        default: return format(for: pluralized.otherValue)
                    }
                } else {
                    return pluralized.otherValue
                }
            case .deleted:
                if languagePackID == "en" {
                    return key
                } else {
                    return try await getTelegramString(by: key, from: "en", arg: arg)
                }
        }
    }
}
