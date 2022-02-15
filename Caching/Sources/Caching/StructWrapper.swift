//
//  StructWrapper.swift
//  
//
//  Created by Егор Яковенко on 14.02.2022.
//

import Foundation

/// A helper class that allows caching structs in NSCache.
/// Pretty simple, actually
class StructWrapper<T>: NSObject {
    let value: T

    init(_ toWrap: T) {
        value = toWrap
    }
}
