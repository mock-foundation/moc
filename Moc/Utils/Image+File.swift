//
//  Image+File.swift
//  Moc
//
//  Created by Егор Яковенко on 23.05.2022.
//

import SwiftUI
import TDLibKit

extension Image {
    init(file: TDLibKit.File) {
        if let nsImage = NSImage(contentsOfFile: file.local.path) {
            self.init(nsImage: nsImage)
        } else {
            self.init("")
        }
    }
}
