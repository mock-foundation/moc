//
//  LighterDarker.swift
//  Moc
//
//  Created by Егор Яковенко on 18.06.2022.
//  Source: https://stackoverflow.com/a/63003757
//

import AppKit

extension NSColor {
    func lighter(by percentage: CGFloat = 30.0) -> NSColor {
        return self.adjustBrightness(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat = 30.0) -> NSColor {
        return self.adjustBrightness(by: -abs(percentage))
    }
    
    func adjustBrightness(by percentage: CGFloat = 30.0) -> NSColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.usingColorSpace(.sRGB)!.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        if b < 1.0 {
            let newB: CGFloat = max(min(b + (percentage/100.0)*b, 1.0), 0.0)
            return NSColor(hue: h, saturation: s, brightness: newB, alpha: a)
        } else {
            let newS: CGFloat = min(max(s - (percentage/100.0)*s, 0.0), 1.0)
            return NSColor(hue: h, saturation: newS, brightness: b, alpha: a)
        }
    }
}
