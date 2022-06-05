//
//  ChatList.swift
//  
//
//  Created by Егор Яковенко on 05.06.2022.
//

public enum ChatList: Codable, Equatable {
    case main
    case archive
    /// A filter chat list with an `id`.
    case filter(Int)
}
