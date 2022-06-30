//
//  URL+FilePath.swift
//  Moc
//
//  Created by Егор Яковенко on 24.06.2022.
//

import Foundation

public extension URL {
    /// Converts a URL to a normal file path.
    var filePath: String? {
        guard self.isFileURL else { return nil }
        
        var path = self.absoluteString
        path = String(path.suffix(from: .init(utf16Offset: 7, in: path)))
        
        return path.removingPercentEncoding
    }
}
