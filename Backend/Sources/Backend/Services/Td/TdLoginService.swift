//
//  TdLoginService.swift
//
//
//  Created by Егор Яковенко on 19.01.2022.
//

import TDLibKit
import Combine

public class TdLoginService: LoginService {
    public func getAuthorizationState() async throws -> AuthorizationState {
        return try await tdApi.getAuthorizationState()
    }
    
    private var tdApi: TdApi = .shared
    
    public var updateSubject: PassthroughSubject<Update, Never> {
        tdApi.client.updateSubject
    }

    public func resendAuthCode() async throws {
        try await tdApi.resendAuthenticationCode()
    }

    public func checkAuth(phoneNumber: String) async throws {
        try await tdApi.setAuthenticationPhoneNumber(
            phoneNumber: phoneNumber,
            settings: nil
        )
    }

    public init() {}

    public func checkAuth(code: String) async throws {
        try await tdApi.checkAuthenticationCode(code: code)
    }

    public func checkAuth(password: String) async throws {
        try await tdApi.checkAuthenticationPassword(password: password)
    }
    
    public func getCountries() async throws -> [CountryInfo] {
        return try await tdApi.getCountries().countries
    }
    
    public func getCountryCode() async throws -> String {
        return try await tdApi.getCountryCode().text
    }

    public func requestQrCodeAuth() async throws {
        try await tdApi.requestQrCodeAuthentication(otherUserIds: nil)
    }
}
