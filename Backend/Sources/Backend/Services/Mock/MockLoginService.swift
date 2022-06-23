//
//  MockLoginDataRepository.swift
//
//
//  Created by Егор Яковенко on 19.01.2022.
//

import Combine
import TDLibKit

public class MockLoginService: LoginService {
    public func resendAuthCode() async throws { }
    
    public func requestQrCodeAuth() async throws { }

    public func checkAuth(phoneNumber _: String) async throws { }

    public func checkAuth(code _: String) async throws { }

    public func checkAuth(password _: String) async throws { }

    public var countries: [CountryInfo] = [
        CountryInfo(
            callingCodes: ["380"],
            countryCode: "UA",
            englishName: "UA",
            isHidden: false,
            name: "Ukraine"
        ),
    ]

    public var countryCode: String = "380"
}
