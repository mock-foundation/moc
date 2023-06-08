// Color+ContrastRatio.swift

import SwiftUI

// Source:
// https://stackoverflow.com/questions/
// 42355778/how-to-compute-color-contrast-ratio-between-two-uicolor-instances
extension Color {
    // swiftlint:disable:next large_tuple
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {
        let components = self.cgColor?.components ?? [0, 0, 0, 0]
        return (components[0], components[1], components[2], components[3])
    }

    func contrastRatio() -> Double {
        let luminance1 = self.luminance()
        let luminance2 = Color("MessageFromRecepientColor").luminance()

        let luminanceDarker = min(luminance1, luminance2)
        let luminanceLighter = max(luminance1, luminance2)

        let contrast = (luminanceLighter + 0.05) / (luminanceDarker + 0.05)

        return contrast
    }

    func luminance() -> Double {
        func adjust(colorComponent: CGFloat) -> CGFloat {
            return (colorComponent < 0.04045) ? (colorComponent / 12.92) : pow((colorComponent + 0.055) / 1.055, 2.4)
        }

        let components = self.components

        return 0.2126 * adjust(
            colorComponent: components.red) + 0.7152 * adjust(
                colorComponent: components.green) + 0.0722 * adjust(
                    colorComponent: components.blue)
    }
}
