//
//  BasicGroupCache.swift
//  
//
//  Created by Егор Яковенко on 15.02.2022.
//

import Foundation
import TDLibKit

/// A basic group cache class.
public class BasicGroupCache: Cache<Int64, BasicGroup> {
    init() {
        super.init(name: "BasicGroupCache")
    }
}
