//
//  NotificationKeys.swift
//  Moc
//
//  Created by Егор Яковенко on 01.01.2022.
//

import Foundation

/// A ton of custom keys for representing notifications from TDLib.
extension NSNotification.Name {
    // MARK: - Authorization states
    static var authorizationStateWaitTdlibParameters: NSNotification.Name {
        return .init(rawValue: "AuthorizationStateWaitTdlibParameters")
    }

    static var authorizationStateWaitEncryptionKey: NSNotification.Name {
        return .init(rawValue: "AuthorizationStateWaitEncryptionKey")
    }

    static var authorizationStateWaitPhoneNumber: NSNotification.Name {
        return .init(rawValue: "AuthorizationStateWaitPhoneNumber")
    }

    static var authorizationStateWaitCode: NSNotification.Name {
        return .init(rawValue: "AuthorizationStateWaitCode")
    }

    static var authorizationStateWaitRegistration: NSNotification.Name {
        return .init(rawValue: "AuthorizationStateWaitRegistration")
    }

    static var authorizationStateWaitPassword: NSNotification.Name {
        return .init(rawValue: "AuthorizationStateWaitPassword")
    }

    static var authorizationStateReady: NSNotification.Name {
        return .init(rawValue: "AuthorizationStateReady")
    }

    static var authorizationStateWaitOtherDeviceConfirmation: NSNotification.Name {
        return .init(rawValue: "AuthorizationStateWaitOtherDeviceConfirmation")
    }

    static var authorizationStateLoggingOut: NSNotification.Name {
        return .init(rawValue: "AuthorizationStateLoggingOut")
    }

    static var authorizationStateClosing: NSNotification.Name {
        return .init(rawValue: "AuthorizationStateClosing")
    }

    static var authorizationStateClosed: NSNotification.Name {
        return .init(rawValue: "AuthorizationStateClosed")
    }

    // MARK: - Chat position
    static var updateChatPosition: NSNotification.Name {
        return .init(rawValue: "UpdateChatPosition")
    }

    static var updateNewMessage: NSNotification.Name {
        return .init("UpdateNewMessage")
    }

    static var updateChatLastMessage: NSNotification.Name {
        return .init("UpdateChatLastMessage")
    }

    static var updateNewChat: NSNotification.Name {
        return .init("UpdateNewChat")
    }
}
