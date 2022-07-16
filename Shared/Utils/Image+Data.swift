//
//  Image+Data.swift
//  Moc
//
//  Created by Егор Яковенко on 16.07.2022.
//  Source: https://gist.github.com/BrentMifsud/dce3fc6a76b8ef519ea7be0a3b050674
//

import Foundation
import SwiftUI
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

extension Image {
    /// Initializes a SwiftUI `Image` from data.
    init(data: Data) {
        #if os(macOS)
        if let nsImage = NSImage(data: data) {
            self.init(nsImage: nsImage)
        } else {
            self.init()
        }
        #elseif os(iOS)
        if let uiImage = UIImage(data: data) {
            self.init(uiImage: uiImage)
        } else {
            self.init()
        }
        #endif
    }
}
