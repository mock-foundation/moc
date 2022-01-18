//
//  DataSourcable.swift
//  
//
//  Created by Егор Яковенко on 18.01.2022.
//

import TDLibKit

/// A base protocol for encapsulating TDLib.
public protocol DataSourcable {
    var tdApi: TdApi { get }
}
