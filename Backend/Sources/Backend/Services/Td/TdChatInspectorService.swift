//
//  TdChatInspectorService.swift
//  
//
//  Created by Егор Яковенко on 05.09.2022.
//

import TDLibKit
import Combine

public class TdChatInspectorService: ChatInspectorService {
    private var tdApi = TdApi.shared
    
    public var updateSubject: PassthroughSubject<TDLibKit.Update, Never> {
        tdApi.client.updateSubject
    }
    
    public init() { }
    
    public func getChat(with id: Int64) async throws -> Chat {
        try await tdApi.getChat(chatId: id)
    }
}
