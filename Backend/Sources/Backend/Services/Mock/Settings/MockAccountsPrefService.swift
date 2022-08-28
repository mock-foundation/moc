//
//  MockAccountsPrefService.swift
//
//
//  Created by Егор Яковенко on 19.01.2022.
//

import TDLibKit
import Combine

public class MockAccountsPrefService: AccountsPrefService {
    public var updateSubject = PassthroughSubject<Update, Never>()
    
    public func setFirstLastNames(_ first: String, _ last: String) async throws { }
    
    public func setUsername(_ username: String) async throws { }
    
    public func setBio(_ bio: String) async throws { }

    public func logOut() async throws {}

    public func getMe() async throws -> User {
        User.mock
    }

    public func getFullInfo() async throws -> UserFullInfo {
        UserFullInfo.mock
    }

    public func getProfilePhotos() async throws -> [ChatPhoto] {
        []
    }

    public func downloadFile(by id: Int, priority _: Int, synchronous _: Bool) async throws -> File {
        throw Error(code: 1, message: "Download file is not working in mock instances")
    }
}
