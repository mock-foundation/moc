//
//  LocalizationService.swift
//  
//
//  Created by Егор Яковенко on 26.10.2022.
//

import TDLibKit

public protocol LocalizationService: Service {
    func getString(by key: String) async throws -> LanguagePackString
    func getStrings(by keys: [String]) async throws ->[LanguagePackString]
}
