//
//  MockChatInspectorService.swift
//  
//
//  Created by Егор Яковенко on 05.09.2022.
//

import TDLibKit
import Combine

public class MockChatInspectorService: ChatInspectorService {
    public var updateSubject = PassthroughSubject<TDLibKit.Update, Never>()
    
    public init() { }
    
    public func getChat(with id: Int64) async throws -> Chat {
        Chat.mock
    }
}
