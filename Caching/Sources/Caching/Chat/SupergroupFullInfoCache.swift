//
//  SupergroupFullInfoCache.swift
//  
//
//  Created by Егор Яковенко on 15.02.2022.
//

import Foundation
import TDLibKit

/// A basic group cache class.
public class SupergroupFullInfoCache: Cache<Int64, SupergroupFullInfo> {
    init() {
        super.init(name: "SupergroupFullInfoCache")
    }
}
