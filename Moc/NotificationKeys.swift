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
    static var authorizationStateWaitTdlibParameters: Notification.Name {
        return .init(rawValue: "AuthorizationStateWaitTdlibParameters")
    }

    static var authorizationStateWaitEncryptionKey: Notification.Name {
        return .init(rawValue: "AuthorizationStateWaitEncryptionKey")
    }

    static var authorizationStateWaitPhoneNumber: Notification.Name {
        return .init(rawValue: "AuthorizationStateWaitPhoneNumber")
    }

    static var authorizationStateWaitCode: Notification.Name {
        return .init(rawValue: "AuthorizationStateWaitCode")
    }

    static var authorizationStateWaitRegistration: Notification.Name {
        return .init(rawValue: "AuthorizationStateWaitRegistration")
    }

    static var authorizationStateWaitPassword: Notification.Name {
        return .init(rawValue: "AuthorizationStateWaitPassword")
    }

    static var authorizationStateReady: Notification.Name {
        return .init(rawValue: "AuthorizationStateReady")
    }

    static var authorizationStateWaitOtherDeviceConfirmation: Notification.Name {
        return .init(rawValue: "AuthorizationStateWaitOtherDeviceConfirmation")
    }

    static var authorizationStateLoggingOut: Notification.Name {
        return .init(rawValue: "AuthorizationStateLoggingOut")
    }

    static var authorizationStateClosing: Notification.Name {
        return .init(rawValue: "AuthorizationStateClosing")
    }

    static var authorizationStateClosed: Notification.Name {
        return .init(rawValue: "AuthorizationStateClosed")
    }

    // MARK: - Chat position
    static var updateChatPosition: Notification.Name {
        return .init(rawValue: "UpdateChatPosition")
    }

    static var updateNewMessage: Notification.Name {
        return .init("UpdateNewMessage")
    }

    static var updateChatLastMessage: Notification.Name {
        return .init("UpdateChatLastMessage")
    }

    static var updateNewChat: Notification.Name {
        return .init("UpdateNewChat")
    }
}
