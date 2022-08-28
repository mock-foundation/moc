//
//  UserFullInfo+Mock.swift
//  
//
//  Created by Егор Яковенко on 28.08.2022.
//

import TDLibKit

extension UserFullInfo {
    static let mock = UserFullInfo(
        bio: FormattedText(entities: [], text: "Bio"),
        botInfo: nil,
        canBeCalled: false,
        groupInCommonCount: 2,
        hasPrivateCalls: false,
        hasPrivateForwards: false,
        isBlocked: true,
        needPhoneNumberPrivacyException: true,
        photo: nil,
        supportsVideoCalls: true)
}
