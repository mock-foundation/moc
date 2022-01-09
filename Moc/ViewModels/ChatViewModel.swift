//
//  ChatViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 01.01.2022.
//

import Resolver
import Foundation
import TDLibKit

class ChatViewModel: ObservableObject {
    @Injected private var tdApi: TdApi

    @Published var messages: [Message] = []
    @Published var chatName: String
    @Published var memberList: [ChatMember]?

    init(chat: Chat) async {
        self.chatName = chat.title
        switch chat.type {
            case .chatTypeBasicGroup(_):
                self.memberList = try? await tdApi.getBasicGroupFullInfo(basicGroupId: chat.id).members
            case .chatTypeSupergroup(_):
                if try! await tdApi.getSupergroupFullInfo(supergroupId: chat.id).canGetMembers {
                    self.memberList = try? await tdApi.getSupergroupMembers(filter: nil, limit: nil, offset: nil, supergroupId: chat.id).members
                } else {
                    self.memberList = nil
                }
            default:
                self.memberList = nil
        }
    }
}
