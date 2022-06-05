//
//  ChatList.swift
//  
//
//  Created by Егор Яковенко on 05.06.2022.
//

import GRDB

public enum ChatList: Codable, Equatable, DatabaseValueConvertible {
    case main
    case archive
    /// A filter chat list with an `id`.
    case filter(Int)
}
