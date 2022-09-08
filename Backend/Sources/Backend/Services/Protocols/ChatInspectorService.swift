//
//  ChatInspectorService.swift
//  
//
//  Created by Егор Яковенко on 04.09.2022.
//

import TDLibKit

public protocol ChatInspectorService: Service {
    func getChat(with id: Int64) async throws -> Chat
}
