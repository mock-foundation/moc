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
        return .init("AuthorizationStateWaitTdlibParameters")
    }

    static var authorizationStateWaitEncryptionKey: NSNotification.Name {
        return .init("AuthorizationStateWaitEncryptionKey")
    }

    static var authorizationStateWaitPhoneNumber: NSNotification.Name {
        return .init("AuthorizationStateWaitPhoneNumber")
    }

    static var authorizationStateWaitCode: NSNotification.Name {
        return .init("AuthorizationStateWaitCode")
    }

    static var authorizationStateWaitRegistration: NSNotification.Name {
        return .init("AuthorizationStateWaitRegistration")
    }

    static var authorizationStateWaitPassword: NSNotification.Name {
        return .init("AuthorizationStateWaitPassword")
    }

    static var authorizationStateReady: NSNotification.Name {
        return .init("AuthorizationStateReady")
    }

    // swiftlint:disable identifier_name
    static var authorizationStateWaitOtherDeviceConfirmation: NSNotification.Name {
        return .init("AuthorizationStateWaitOtherDeviceConfirmation")
    }

    static var authorizationStateLoggingOut: NSNotification.Name {
        return .init("AuthorizationStateLoggingOut")
    }

    static var authorizationStateClosing: NSNotification.Name {
        return .init("AuthorizationStateClosing")
    }

    static var authorizationStateClosed: NSNotification.Name {
        return .init("AuthorizationStateClosed")
    }

    // MARK: - Chat updates
    static var updateChatPosition: NSNotification.Name {
        return .init("UpdateChatPosition")
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
