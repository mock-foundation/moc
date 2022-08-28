//
//  MainService.swift
//  
//
//  Created by Егор Яковенко on 03.06.2022.
//

import Combine
import TDLibKit
import Storage

public protocol MainService: Service {
    func getFilters() throws -> [ChatFilter]
    func getUnreadCounters() throws -> [UnreadCounter]
    func getChat(by id: Int64) async throws -> Chat
}
