//
//  AccountsPrefViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 20.01.2022.
//

import Foundation
import Backend
import Resolver
import Utilities
import Logs
import Combine

class AccountsPrefViewModel: ObservableObject {
    var logger = Logs.Logger(category: "Preferences", label: "AccountPaneUI")
    @Injected private var service: any AccountsPrefService
    
    @Published var firstName: String = "" {
        didSet {
            if firstName.count > 64 {
                firstName = String(firstName.prefix(64))
                SystemUtils.playAlertSound()
            }
        }
    }
    @Published var lastName: String = "" {
        didSet {
            if lastName.count > 64 {
                lastName = String(lastName.prefix(64))
                SystemUtils.playAlertSound()
            }
        }
    }
    
    var updateSubject: PassthroughSubject<Update, Never> { service.updateSubject }
    
    func updateNames() {
        Task {
            do {
                try await service.setFirstLastNames(firstName, lastName)
            } catch let error {
                logger.error(error)
            }
        }
    }
    
    func logOut() async throws {
        try await service.logOut()
    }
    
    func setUsername(_ username: String) async throws {
        try await service.setUsername(username)
    }
    
    func setBio(_ bio: String) async throws {
        try await service.setBio(bio)
    }
    
    func getMe() async throws -> User {
        try await service.getMe()
    }
    
    func getMeFullInfo() async throws -> UserFullInfo {
        try await service.getFullInfo()
    }
    
    func getProfilePhotos() async throws -> [ChatPhoto] {
        try await service.getProfilePhotos()
    }
}
