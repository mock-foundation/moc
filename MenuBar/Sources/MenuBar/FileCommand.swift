//
//  FileCommand.swift
//  
//
//  Created by Егор Яковенко on 10.10.2022.
//

import SwiftUI
import Utilities

public struct FileCommand: Commands {
    public init() { }
    
    public var body: some Commands {
        CommandGroup(replacing: .newItem) {
            EmptyView()
        }
    }
}
