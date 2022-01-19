//
//  LoginDataSource.swift
//  
//
//  Created by Егор Яковенко on 19.01.2022.
//

import TDLibKit
import Combine

public protocol LoginDataSource {
    /// Requests login using a QR code.
    func requestQrCodeAuth() async throws

    /// Sets an authentication phone number. On real implementeation
    /// corresponds to `setAuthenticationPhoneNumber(phoneNumber:settings:)`.
    func setAuthPhoneNumber(_ phoneNumber: String) async throws

    /// Checks auth code
    func checkAuth(code: String) async throws

    /// Checks auth password
    func checkAuth(password: String) async throws

    var countries: [CountryInfo] { get async throws }

    var countryCode: String { get async throws }
}
