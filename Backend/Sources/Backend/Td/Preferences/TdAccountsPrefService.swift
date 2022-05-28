//
//  TdAccountsPrefService.swift
//
//
//  Created by Егор Яковенко on 19.01.2022.
//

import TDLibKit

public class TdAccountsPrefService: AccountsPrefService {
    public var tdApi: TdApi = .shared[0]

    public func logOut() async throws {
        _ = try await tdApi.logOut()
    }

    public func set(firstName: String) async throws {
        _ = try await tdApi.setName(firstName: firstName, lastName: "")
    }

    public func set(lastName: String) async throws {
        _ = try await tdApi.setName(firstName: "", lastName: lastName)
    }

    public func set(username: String) async throws {
        _ = try await tdApi.setUsername(username: username)
    }

    public func set(bio: String) async throws {
        _ = try await tdApi.setBio(bio: bio)
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
