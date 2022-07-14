//
//  Constants.swift
//  Moc
//
//  Created by Егор Яковенко on 27.01.2022.
//

import Foundation

public struct Constants {
    public static let unsupportedMessage = "This message is not supported; please update Moc to view it."
    public static let sidebarSizeDefaultsKey = "NSTableViewDefaultSizeMode"
    
    // A blank private init so this struct is not possible to instantiate
    private init() { }
}

public extension Notification.Name {
    static let scrollToMessage = Notification.Name(rawValue: "ScrollToMessage")
}
