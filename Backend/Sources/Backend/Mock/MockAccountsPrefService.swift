//
//  MockAccountsPrefService.swift
//
//
//  Created by Егор Яковенко on 19.01.2022.
//

import TDLibKit

public class MockAccountsPrefService: AccountsPrefService {
    public func set(firstName _: String) async throws {}

    public func set(lastName _: String) async throws {}

    public func set(username _: String) async throws {}

    public func set(bio _: String) async throws {}

    public func logOut() async throws {}

    public func getMe() async throws -> User {
        User(
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
        UserFullInfo(
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
        []
    }

    public func downloadFile(fileId _: Int, priority _: Int, synchronous _: Bool) async throws -> File {
        throw Error(code: 1, message: "Download file is not working in mock instances")
    }
}
