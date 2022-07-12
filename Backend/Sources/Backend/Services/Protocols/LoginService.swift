//
//  LoginService.swift
//
//
//  Created by Егор Яковенко on 19.01.2022.
//

import Combine
import TDLibKit

public protocol LoginService: Service {
    /// Requests login using a QR code.
    func requestQrCodeAuth() async throws

    /// Sets an authentication phone number. On real implementeation
    /// corresponds to `setAuthenticationPhoneNumber(phoneNumber:settings:)`.
    func checkAuth(phoneNumber: String) async throws

    /// Checks auth code
    func checkAuth(code: String) async throws

    /// Checks auth password
    func checkAuth(password: String) async throws
    
    func resendAuthCode() async throws

    var countries: [CountryInfo] { get async throws }

    var countryCode: String { get async throws }
}
