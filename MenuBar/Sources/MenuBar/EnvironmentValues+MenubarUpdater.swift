//
//  EnvironmentValues+MenubarUpdater.swift
//  
//
//  Created by Егор Яковенко on 09.10.2022.
//

import SwiftUI
import Combine

public extension EnvironmentValues {
    var menubarUpdater: MenubarUpdater {
        get {
            self[MenubarUpdater.self]
        }
        set {
            self[MenubarUpdater.self] = newValue
        }
    }
}
