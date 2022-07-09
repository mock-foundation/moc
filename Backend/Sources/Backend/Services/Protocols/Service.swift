//
//  File.swift
//  
//
//  Created by Егор Яковенко on 09.07.2022.
//

import TDLibKit

/// A base service.
public protocol Service {
    var updateStream: AsyncStream<Update> { get }
}
