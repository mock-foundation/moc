//
//  MockAccountsPrefService.swift
//  
//
//  Created by Егор Яковенко on 19.01.2022.
//

import TDLibKit

public class MockAccountsPrefService: AccountsPrefService {
    public func set(firstName: String) async throws { }

    public func set(lastName: String) async throws { }

    public func set(username: String) async throws { }

    public func set(bio: String) async throws { }

    public func logOut() async throws { }

    public func getMe() async throws -> User {
        return User(
            firstName: "First name",
            haveAccess: true,
            id: 0,
            isContact: false,
            isFake: false,
            isMutualContact: false,
            isScam: false,
            isSupport: false,
            isVerified: true,
            languageCode: "ua",
            lastName: "Last name",
            phoneNumber: "+0987654",
            profilePhoto: nil,
            restrictionReason: "",
            status: .userStatusEmpty,
            type: .userTypeRegular,
            username: "username"
        )
    }

    public func getFullInfo() async throws -> UserFullInfo {
        return UserFullInfo(
            bio: "Bio",
            canBeCalled: false,
            commands: [],
            description: "Descripion",
            groupInCommonCount: 2,
            hasPrivateCalls: false,
            hasPrivateForwards: false,
            isBlocked: true,
            needPhoneNumberPrivacyException: true,
            photo: nil,
            shareText: "Share text",
            supportsVideoCalls: true
        )
    }

    public func getProfilePhotos() async throws -> [ChatPhoto] {
        return []
    }

    public func downloadFile(fileId: Int, priority: Int, synchronous: Bool) async throws -> File {
        throw Error(code: 1, message: "Download file is not working in mock instances")
    }
}
