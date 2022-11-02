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
    public static let languagePacksDatabasePath: String = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        print(urls)
        var url: URL?
        if #available(macOS 13, iOS 16, *) {
            url = urls.first!
                .appending(path: "Moc")
                .appending(path: "languagePacks.sqlite")
        } else {
            url = urls.first!
                .appendingPathComponent("Moc")
                .appendingPathComponent("languagePacks.sqlite")
        }
        try! FileManager.default.createDirectory(at: url!.deletingLastPathComponent(), withIntermediateDirectories: true)
        return url!.absoluteString.replacingOccurrences(of: "file://", with: "")
    }()
    
    // A blank private init so this struct is not possible to instantiate
    private init() { }
}

public extension Notification.Name {
    static let scrollToMessage = Notification.Name(rawValue: "ScrollToMessage")
}
