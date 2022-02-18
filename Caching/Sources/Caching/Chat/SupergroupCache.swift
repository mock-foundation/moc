//
//  SupergroupCache.swift
//  
//
//  Created by Егор Яковенко on 15.02.2022.
//

import Foundation
import TDLibKit

/// A basic group cache class.
public class SupergroupCache: Cache<Int64, Supergroup> {
    init() {
        super.init(name: "SupergroupCache")
    }
}
