//
//  ColorExtension.swift
//
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI

public extension Color {
    init(fromUserId userId: Int64) {
        let colors: [Color] = [
            .red,
            .green,
            .yellow,
            .blue,
            .purple,
            .pink,
            .blue,
            .orange,
        ]
        let id = Int(String(userId).replacingOccurrences(of: "-100", with: "-"))!

        #if os(macOS)
        self.init(nsColor: NSColor(colors[[0, 7, 4, 1, 6, 3, 5][abs(id % 7)]]))
        #elseif os(iOS)
        self.init(uiColor: UIColor(colors[[0, 7, 4, 1, 6, 3, 5][abs(id % 7)]]))
        #endif
    }
}

//public extension Color {
//    var isDark: Bool {
//        // swiftlint:disable identifier_name
//        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
//        NSColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
//        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
//        return lum < 0.50
//    }
//}
