//
//  ChatCache.swift
//  
//
//  Created by Егор Яковенко on 14.02.2022.
//

import Foundation
import TDLibKit

/// A chat cache class.
public class ChatCache: Cache<Int64, Chat> {
    init() {
        super.init(name: "ChatCache")
    }
}
