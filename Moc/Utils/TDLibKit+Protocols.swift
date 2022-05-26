//
//  TDLibKit+Identifiable.swift
//  
//
//  Created by Егор Яковенко on 26.02.2022.
//
import TDLibKit

extension Chat: Identifiable { }

extension ChatFilter: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(excludeArchived)
        hasher.combine(excludeMuted)
        hasher.combine(excludeRead)
        hasher.combine(excludedChatIds)
        hasher.combine(iconName)
        hasher.combine(includeBots)
        hasher.combine(includeChannels)
        hasher.combine(includeContacts)
        hasher.combine(includeGroups)
        hasher.combine(includeNonContacts)
        hasher.combine(includedChatIds)
        hasher.combine(pinnedChatIds)
        hasher.combine(title)
    }
}

extension ChatFilterInfo: Hashable, Identifiable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(iconName)
        hasher.combine(id)
    }
}
