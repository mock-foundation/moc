//
//  TdLocalizationService.swift
//  
//
//  Created by Егор Яковенко on 26.10.2022.
//

import Combine
import TDLibKit

public class TdLocalizationService: LocalizationService {
    private let tdApi = TdApi.shared
    private var subscribers: [AnyCancellable] = []
    private var languagePackID = "en"
    
    public var updateSubject: PassthroughSubject<Update, Never> {
        return tdApi.client.updateSubject
    }
    
    public init() {
        updateSubject
            .sink { value in
                if case let .option(option) = value {
                    switch option.name {
                        case "language_pack_id":
                            switch option.value {
                                case let .string(string): self.languagePackID = string.value
                                default: break
                            }
                        default: break
                    }
                }
            }
            .store(in: &subscribers)
    }
    
    public func getString(by key: String) async throws -> LanguagePackString {
        return try await getStrings(
            by: [key]
        ).first ?? LanguagePackString(key: key, value: .deleted)
    }
    
    public func getStrings(by keys: [String]) async throws -> [LanguagePackString] {
        return try await tdApi.getLanguagePackStrings(
            keys: keys,
            languagePackId: languagePackID
        ).strings
    }
}
