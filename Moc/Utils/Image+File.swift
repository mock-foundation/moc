//
//  Image+File.swift
//  Moc
//
//  Created by Егор Яковенко on 23.05.2022.
//

import SwiftUI
import Utilities
import TDLibKit

extension Image {
    init(file: TDLibKit.File) {
        #if os(macOS)
        if let nsImage = NSImage(contentsOfFile: file.local.path) {
            self.init(nsImage: nsImage)
        } else {
            self.init()
        }
        #elseif os(iOS)
        if let uiImage = UIImage(contentsOfFile: file.local.path) {
            self.init(uiImage: uiImage)
        } else {
            self.init()
        }
        #endif
    }
}
