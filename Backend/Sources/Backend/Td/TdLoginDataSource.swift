//
//  TdLoginDataSource.swift
//  
//
//  Created by Егор Яковенко on 19.01.2022.
//

import TDLibKit

public class TdLoginDataSource: LoginDataSource {
    public func setAuthPhoneNumber(_ phoneNumber: String) async throws {

    }

    public func checkAuth(code: String) async throws {

    }

    public func checkAuth(password: String) async throws {

    }

    public var countries: [CountryInfo]

    public var countryCode: String

    private var tdApi: TdApi = .shared[0]

    public func requestQrCodeAuth() async throws {
        try await tdApi.requestQrCodeAuthentication(otherUserIds: nil)
    }
}
