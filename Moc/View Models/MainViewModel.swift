//
//  MainViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 01.01.2022.
//

import Resolver
import Foundation
import TDLibKit

class MainViewModel: ObservableObject {
    @Published var chatList: [ChatItem] = []

    @Injected private var tdApi: TdApi

    func update(chats: [ChatItem]) {
        self.chatList = chats
    }
}
