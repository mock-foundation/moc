//
//  Constants.swift
//  Moc
//
//  Created by Егор Яковенко on 27.01.2022.
//

import Foundation

public enum Constants {
    public static let unsupportedMessage = "This message is not supported; please update Moc to view it."
    public static let sidebarSizeDefaultsKey = "NSTableViewDefaultSizeMode"
    public static let languagePacksDatabasePath: String = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        print(urls)
        var url = urls.first!
                .appending(path: "Moc")
                .appending(path: "languagePacks.sqlite")
        try! FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        return url.absoluteString.replacingOccurrences(of: "file://", with: "")
    }()
}

public extension Notification.Name {
    static let scrollToMessage = Notification.Name(rawValue: "ScrollToMessage")
    static let updateL10nManager = Notification.Name(rawValue: "UpdateL10nManager")
}
