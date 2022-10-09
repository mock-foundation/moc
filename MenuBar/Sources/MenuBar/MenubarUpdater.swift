//
//  MenubarUpdater.swift
//  
//
//  Created by Егор Яковенко on 09.10.2022.
//

import Combine
import SwiftUI

public class MenubarUpdater {
    public var publisher: AnyPublisher<MenubarAction, Never> {
        subject.eraseToAnyPublisher()
    }
    
    var subject = PassthroughSubject<MenubarAction, Never>()
    
    public init() { }
}

extension MenubarUpdater: EnvironmentKey {
    public static var defaultValue: MenubarUpdater {
        return MenubarUpdater()
    }
}
