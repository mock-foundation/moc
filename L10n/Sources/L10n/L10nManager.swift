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
    static let shared = L10nManager()
    private let tdApi = TdApi.shared
    private var subscribers: [AnyCancellable] = []
    private var languagePackID = "en"
    
    subscript(key: String, source: L10nSource = .automatic) -> String {
        return getString(by: key, source: source)
    }
    
    func getString(by key: String, source: L10nSource = .automatic) async throws -> String {
        // TODO: Implement string retriaval
        switch source {
            case .strings:
                return getLocalizableString(by: key)
            case .telegram:
                return getTelegramString(by: key)
            case .automatic:
                let localizable = getLocalizableString(by: key)
                if localizable == key { // If not found
                    return getTelegramString(by: key)
                } else {
                    return localizable
                }
        }
    }
    
    func getLocalizableString(by key: String) -> String {
        print("WARNING: getLocalizableString(by:) is not implemented")
        return key
    }
    
    func getTelegramString(by key: String) async throws -> String {
        return try await gtdApi.getLanguagePackStrings(
            keys: keys,
            languagePackId: languagePackID
        ).strings.first ?? LanguagePackString(key: key, value: .deleted)
    }
}

