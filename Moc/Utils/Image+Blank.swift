//
//  Image+Blank.swift
//  Moc
//
//  Created by Егор Яковенко on 23.05.2022.
//

import SwiftUI

extension Image {
    init() {
        #if os(macOS)
        self.init(nsImage: NSImage())
        #elseif os(iOS)
        self.init(uiImage: UIImage())
        #endif
    }
}
