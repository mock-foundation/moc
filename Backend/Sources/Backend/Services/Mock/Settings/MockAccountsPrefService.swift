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
    
    public func set(firstName _: String, lastName _: String) async throws {}

    public func set(username _: String) async throws {}

    public func set(bio _: String) async throws {}

    public func logOut() async throws {}

    public func getMe() async throws -> User {
        User(
            addedToAttachmentMenu: false,
            firstName: "First name",
            haveAccess: true,
            id: 0,
            isContact: false,
            isFake: false,
            isMutualContact: false,
            isPremium: true,
            isScam: false,
            isSupport: false,
            isVerified: true,
            languageCode: "ua",
            lastName: "Last name",
            phoneNumber: "+0987654",
            profilePhoto: nil,
            restrictionReason: "",
            status: .empty,
            type: .regular,
            username: "username"
        )
    }

    public func getFullInfo() async throws -> UserFullInfo {
        UserFullInfo(
            bio: FormattedText(entities: [], text: "Bio"),
            botInfo: nil,
            canBeCalled: false,
            groupInCommonCount: 2,
            hasPrivateCalls: false,
            hasPrivateForwards: false,
            isBlocked: true,
            needPhoneNumberPrivacyException: true,
            photo: nil,
            supportsVideoCalls: true
        )
    }

    public func getProfilePhotos() async throws -> [ChatPhoto] {
        []
    }

    public func downloadFile(by id: Int, priority _: Int, synchronous _: Bool) async throws -> File {
        throw Error(code: 1, message: "Download file is not working in mock instances")
    }
}
