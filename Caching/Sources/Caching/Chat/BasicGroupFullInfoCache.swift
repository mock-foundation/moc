//
//  BasicGroupFullInfoCache.swift
//  
//
//  Created by Егор Яковенко on 15.02.2022.
//

import Foundation
import TDLibKit

/// A basic group cache class. To read and write to cache, use subscript syntax.
public class BasicGroupFullInfoCache: Cache<Int64, BasicGroupFullInfo> {
    init() {
        super.init(name: "BasicGroupFullInfoCache")
    }
}
