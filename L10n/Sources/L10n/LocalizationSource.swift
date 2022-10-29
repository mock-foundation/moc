//
//  LocalizationSource.swift
//  
//
//  Created by Егор Яковенко on 19.10.2022.
//

public enum LocalizationSource {
    /// Gets a string from local Localizable.strings
    case strings
    /// Gets a string from Telegram's translation platform
    case telegram
    /// Try Localizable.strings first, and then try TTP(Telegram Translation Platform)
    case automatic
}
