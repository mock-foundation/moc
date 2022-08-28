//
//  TdAccountsPrefService.swift
//
//
//  Created by Егор Яковенко on 19.01.2022.
//

import TDLibKit
import Combine

public class TdAccountsPrefService: AccountsPrefService {
    public var updateSubject: PassthroughSubject<TDLibKit.Update, Never> {
        tdApi.client.updateSubject
    }
    
    public var tdApi: TdApi = .shared

    public func logOut() async throws {
        try await tdApi.logOut()
    }
    
    public func setFirstLastNames(_ first: String, _ last: String) async throws {
        try await tdApi.setName(firstName: first, lastName: last)
    }

    public func setUsername(_ username: String) async throws {
        try await tdApi.setUsername(username: username)
    }

    public func setBio(_ bio: String) async throws {
        try await tdApi.setBio(bio: bio)
    }

    public func getMe() async throws -> User {
        try await tdApi.getMe()
    }

    public func getFullInfo() async throws -> UserFullInfo {
        try await tdApi.getUserFullInfo(userId: try await getMe().id)
    }

    public func getProfilePhotos() async throws -> [ChatPhoto] {
        try await tdApi.getUserProfilePhotos(limit: 100, offset: 0, userId: try await getMe().id).photos
    }

    public func downloadFile(
        by id: Int,
        priority: Int = 32,
        synchronous: Bool = true
    ) async throws -> File {
        try await tdApi.downloadFile(
            fileId: id,
            limit: 0,
            offset: 0,
            priority: priority,
            synchronous: synchronous
        )
    }

    public init() {}
}
