//
//  TdLoginService.swift
//
//
//  Created by Егор Яковенко on 19.01.2022.
//

import TDLibKit

public class TdLoginService: LoginService {
    private var tdApi: TdApi = .shared[0]
    
    public var updateStream: AsyncStream<TDLibKit.Update> {
        tdApi.client.updateStream
    }

    public func resendAuthCode() async throws {
        _ = try await tdApi.resendAuthenticationCode()
    }

    public func checkAuth(phoneNumber: String) async throws {
        _ = try await tdApi.setAuthenticationPhoneNumber(
            phoneNumber: phoneNumber,
            settings: nil
        )
    }

    public init() {}

    public func checkAuth(code: String) async throws {
        _ = try await tdApi.checkAuthenticationCode(code: code)
    }

    public func checkAuth(password: String) async throws {
        _ = try await tdApi.checkAuthenticationPassword(password: password)
    }

    public var countries: [CountryInfo] {
        get async throws {
            (try? await tdApi.getCountries().countries) ?? []
        }
    }

    public var countryCode: String {
        get async throws {
            (try? await tdApi.getCountryCode().text) ?? "en"
        }
    }

    public func requestQrCodeAuth() async throws {
        _ = try await tdApi.requestQrCodeAuthentication(otherUserIds: nil)
    }
}
