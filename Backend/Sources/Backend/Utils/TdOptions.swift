//
//  TdOptions.swift
//
//
//  Created by Егор Яковенко on 28.06.2022.
//

import TDLibKit

public extension String {
    
    /// `[Boolean, writable]` If true, text entities will be automatically parsed in all `
    /// inputMessageText` objects
    static let alwaysParseMarkdown = "always_parse_markdown"
    
    /// `[Boolean, writable]` If true, new chats from non-contacts will be automatically
    ///  archived and muted. The option can be set only if the option
    ///  `can_archive_and_mute_new_chats_from_unknown_users` is true.` getOption`
    ///  needs to be called explicitly to fetch the latest value of the option, changed from another
    ///  device
    static let archiveAndMuteNewChatsFromUnknownUsers = "archive_and_mute_new_chats_from_unknown_users"
    
    /// `[Boolean, writable]` If true, animated emoji will be disabled and shown as plain emoji
    static let disableAnimatedEmoji = "disable_animated_emoji"
    
    /// `[Boolean, writable]` If true, notifications about the user's contacts who have joined
    /// Telegram will be disabled. User will still receive the corresponding message in the private
    /// chat.` getOption` needs to be called explicitly to fetch the latest value of the option,
    /// changed from another device
    static let disableContactRegisteredNotifications = "disable_contact_registered_notifications"
    
    /// `[Boolean, writable]` If true, persistent network statistics will be disabled, which
    /// significantly reduces disk usage
    static let disablePersistentNetworkStatistics = "disable_persistent_network_statistics"
    
    /// `[Boolean, writable]` If true, notifications about outgoing scheduled messages
    /// that were sent will be disabled
    static let disableSendScheduledMessageNotifications = "disable_sent_scheduled_message_notifications"
    
    /// `[Boolean, writable]` If true, protection from external time adjustment will be
    /// disabled, which significantly reduces disk usage
    static let disableTimeAdjustmentProtection = "disable_time_adjustment_protection"
    
    /// `[Boolean, writable]` If true, support for top chats and statistics collection is disabled
    static let disableTopChats = "disable_top_chats"
    
    /// `[Boolean, writable]` If true, allows to skip all updates received while the TDLib
    /// instance was not running. The option does nothing if the database or secret chats are used
    static let ignoreBackgroundUpdates = "ignore_background_updates"
    
    /// `[Boolean, writable]` Online status of the current user
    static let online = "online"
}
