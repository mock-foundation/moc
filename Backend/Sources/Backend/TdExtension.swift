//
//  TdExtension.swift
//  
//
//  Created by Егор Яковенко on 18.01.2022.
//

import TDLibKit

public extension TdApi {
    /// A list of shared instances. Why list? There could be multiple `TDLib` instances
    /// with multiple clients and multiple windows, which use their `TDLib` instance.
    /// Right now there is no multi-window and multi-account support, so just
    /// use `shared[0]`.
    static var shared: [TdApi] = []
}
