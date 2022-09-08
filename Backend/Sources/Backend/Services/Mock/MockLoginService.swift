//
//  MockLoginDataRepository.swift
//
//
//  Created by Егор Яковенко on 19.01.2022.
//

import Combine
import TDLibKit

public class MockLoginService: LoginService {
    public func getAuthorizationState() async throws -> AuthorizationState {
        return .ready
    }
    
    public var updateSubject = PassthroughSubject<Update, Never>()
    
    public func resendAuthCode() async throws { }
    
    public func requestQrCodeAuth() async throws { }

    public func checkAuth(phoneNumber _: String) async throws { }

    public func checkAuth(code _: String) async throws { }

    public func checkAuth(password _: String) async throws { }
    
    public func getCountries() async throws -> [CountryInfo] {
        return [CountryInfo(
            callingCodes: ["380"],
            countryCode: "UA",
            englishName: "UA",
            isHidden: false,
            name: "Ukraine"
        )]
    }
    
    public func getCountryCode() async throws -> String {
        "UA"
    }
}
