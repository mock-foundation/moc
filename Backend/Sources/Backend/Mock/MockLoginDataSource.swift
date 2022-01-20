//
//  MockLoginDataSource.swift
//  
//
//  Created by Егор Яковенко on 19.01.2022.
//

import Combine
import TDLibKit

public class MockLoginDataSource: LoginDataSource {
    public func requestQrCodeAuth() async throws {

    }

    public func checkAuth(phoneNumber: String) async throws {

    }

    public func checkAuth(code: String) async throws {
        
    }

    public func checkAuth(password: String) async throws {

    }

    public var countries: [CountryInfo] = [
        CountryInfo(
            callingCodes: ["380"],
            countryCode: "UA",
            englishName: "UA",
            isHidden: false,
            name: "Ukraine"
        )
    ]

    public var countryCode: String = "380"
}
