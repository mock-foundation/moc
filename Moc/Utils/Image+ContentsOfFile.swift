//
//  Image+ContentsOfFile.swift
//  Moc
//
//  Created by Егор Яковенко on 24.06.2022.
//

import SwiftUI

extension Image {
    init(contentsOfFile path: String) {
        #if os(macOS)
        self.init(nsImage: NSImage(contentsOfFile: path)!)
        #elseif os(iOS)
        self.init(uiImage: UIImage(contentsOfFile: path)!)
        #endif
    }
}
