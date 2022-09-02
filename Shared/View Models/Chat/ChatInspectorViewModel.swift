//
//  ChatInspectorViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 02.09.2022.
//

import SwiftUI
import Combine

class ChatInspectorViewModel: ObservableObject {
    var chatId: Int64
    
    init(chatId: Int64) {
        self.chatId = chatId
    }
}
