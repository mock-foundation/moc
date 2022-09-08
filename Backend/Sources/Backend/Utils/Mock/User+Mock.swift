//
//  User+Mock.swift
//  
//
//  Created by Егор Яковенко on 28.08.2022.
//

import TDLibKit

extension User {
    static let mock = User(
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
        username: "username")
}
