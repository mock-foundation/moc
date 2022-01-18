//
//  ColorExtension.swift
//  
//
//  Created by Егор Яковенко on 18.01.2022.
//

import SwiftUI

public extension Color {
    var isDark: Bool {
        // swiftlint:disable identifier_name
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        NSColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return lum < 0.50
    }
}
