//
//  NotificationKeys.swift
//  Moc
//
//  Created by Егор Яковенко on 01.01.2022.
//

import Foundation

/// A ton of custom keys for representing notifications from TDLib.
public extension NSNotification.Name {
    // MARK: - Authorization states
    
    static var authorizationStateWaitTdlibParameters: NSNotification.Name {
        .init("AuthorizationStateWaitTdlibParameters")
    }
    
    static var authorizationStateWaitEncryptionKey: NSNotification.Name {
        .init("AuthorizationStateWaitEncryptionKey")
    }
    
    static var authorizationStateWaitPhoneNumber: NSNotification.Name {
        .init("AuthorizationStateWaitPhoneNumber")
    }
    
    static var authorizationStateWaitCode: NSNotification.Name {
        .init("AuthorizationStateWaitCode")
    }
    
    static var authorizationStateWaitRegistration: NSNotification.Name {
        .init("AuthorizationStateWaitRegistration")
    }
    
    static var authorizationStateWaitPassword: NSNotification.Name {
        .init("AuthorizationStateWaitPassword")
    }
    
    static var authorizationStateReady: NSNotification.Name {
        .init("AuthorizationStateReady")
    }
    
    // swiftlint:disable identifier_name
    static var authorizationStateWaitOtherDeviceConfirmation: NSNotification.Name {
        .init("AuthorizationStateWaitOtherDeviceConfirmation")
    }
    
    static var authorizationStateLoggingOut: NSNotification.Name {
        .init("AuthorizationStateLoggingOut")
    }
    
    static var authorizationStateClosing: NSNotification.Name {
        .init("AuthorizationStateClosing")
    }
    
    static var authorizationStateClosed: NSNotification.Name {
        .init("AuthorizationStateClosed")
    }
    
    // MARK: - Chat updates
    
    static var updateChatPosition: NSNotification.Name {
        .init("UpdateChatPosition")
    }
    
    static var updateNewMessage: NSNotification.Name {
        .init("UpdateNewMessage")
    }
    
    static var updateChatLastMessage: NSNotification.Name {
        .init("UpdateChatLastMessage")
    }
    
    static var updateChatDraftMessage: Notification.Name {
        .init(rawValue: "UpdateChatDraftMessage")
    }
    
    static var updateNewChat: NSNotification.Name {
        .init("UpdateNewChat")
    }
    
    static var updateFile: NSNotification.Name {
        .init(rawValue: "UpdateFile")
    }
    
    static var updateChatFilters: Notification.Name {
        .init(rawValue: "UpdateChatFilters")
    }
    
    static var updateUnreadChatCount: Notification.Name {
        .init(rawValue: "UpdateUnreadChatCount")
    }
    
    static var updateUnreadMessageCount: Notification.Name {
        .init(rawValue: "UpdateUnreadMessageCount")
    }
    
    static var updateConnectionState: Notification.Name {
        .init(rawValue: "UpdateConnectionState")
    }
}
