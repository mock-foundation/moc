//
//  MainService.swift
//  
//
//  Created by Егор Яковенко on 03.06.2022.
//

import Combine
import TDLibKit
import Caching

public protocol MainService {
    func getFilters() throws -> [ChatFilter]
    func getUnreadCounters() throws -> [UnreadCounter]
    func getChat(by id: Int64) async throws -> Chat
    var updateStream: AsyncStream<Update> { get }
}
