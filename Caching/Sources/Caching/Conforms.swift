//
//  File.swift
//  
//
//  Created by Егор Яковенко on 28.02.2022.
//

import Foundation
import TDLibKit

extension User: AutoCacheable {
    typealias CacheKey = Int64
}

extension Chat: AutoCacheable {
    typealias CacheKey = Int64
}

extension BasicGroup: AutoCacheable {
    typealias CacheKey = Int64
}

extension BasicGroupFullInfo: AutoCacheable {
    typealias CacheKey = Int64
}

extension Supergroup: AutoCacheable {
    typealias CacheKey = Int64
}

extension SupergroupFullInfo: AutoCacheable {
    typealias CacheKey = Int64
}
