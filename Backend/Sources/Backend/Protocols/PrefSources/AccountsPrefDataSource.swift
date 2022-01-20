//
//  AccountsPrefDataSource.swift
//  
//
//  Created by Егор Яковенко on 19.01.2022.
//

import TDLibKit

public protocol AccountsPrefDataSource {
    func logOut() async throws

    func set(firstName: String) async throws
    func set(lastName: String) async throws
    func set(username: String) async throws
    func set(bio: String) async throws
    func getMe() async throws -> User
    func getFullInfo() async throws -> UserFullInfo
    func getProfilePhotos() async throws -> [ChatPhoto]
    func downloadFile(fileId: Int, priority: Int, synchronous: Bool) async throws -> File
}
