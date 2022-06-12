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
}
