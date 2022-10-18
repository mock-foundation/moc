//
//  Binding+DidSet.swift
//  
//
//  Created by Егор Яковенко on 12.10.2022.
//

import SwiftUI

public extension Binding {
    func didSet(execute: @escaping (Value) -> Void) -> Binding {
        return Binding(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                execute($0)
            }
        )
    }
}
