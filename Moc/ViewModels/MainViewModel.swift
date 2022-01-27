//
//  MainViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 01.01.2022.
//

import Resolver
import SwiftUI
import TDLibKit

class MainViewModel: ObservableObject {
    // MARK: - Chat lists

    @Published var mainChatList: [Chat] = []
    @Published var archiveChatList: [Chat] = []
    @Published var folderChatLists: [Int: [Chat]] = [:]

    /// For chats that have not received updateChatPosition update, and are waiting for distribution.
    var unorderedChatList: [Chat] = []
}
