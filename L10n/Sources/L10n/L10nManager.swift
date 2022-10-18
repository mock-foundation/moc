//
//  L10nManager.swift
//  
//
//  Created by Егор Яковенко on 19.10.2022.
//

import L10n_swift

public struct L10nManager {
    static let shared = L10nManager()
    
    subscript(key: String, source: L10nSource = .automatic) -> String {
        return getString(by: key, source: source)
    }
    
    func getString(by key: String, source: L10nSource = .automatic) -> String {
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
        fatalError("getLocalizableString(by:) is not implemented")
    }
    
    func getTelegramString(by key: String) -> String {
        fatalError("getTelegramString(by:) is not implemented")
    }
}

