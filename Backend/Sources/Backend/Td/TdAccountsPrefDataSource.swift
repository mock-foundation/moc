//
//  TdAccountsPrefDataSource.swift
//  
//
//  Created by Егор Яковенко on 19.01.2022.
//

import TDLibKit

public class TdAccountsPrefDataSource: AccountsPrefDataSource {
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

    public func getMe() async throws -> User {
        return try await tdApi.getMe()
    }

    public func getFullInfo() async throws -> UserFullInfo {
        return try await tdApi.getUserFullInfo(userId: try await getMe().id)
    }

    public func getProfilePhotos() async throws -> [ChatPhoto] {
        return try await tdApi.getUserProfilePhotos(limit: 100, offset: 0, userId: try await getMe().id).photos
    }

    public func downloadFile(
        fileId: Int,
        priority: Int = 32,
        synchronous: Bool = true
    ) async throws -> File {
        return try await tdApi.downloadFile(
            fileId: fileId,
            limit: 0,
            offset: 0,
            priority: priority,
            synchronous: synchronous
        )
    }
}
