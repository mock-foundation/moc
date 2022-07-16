//
//  PlaceholderStyle.swift
//
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI

public enum PlaceholderStyle {
    case miniature
    case small
    case normal
    case medium
    case large
    
    var font: Font {
        switch self {
            case .miniature:
                return .system(size: 14, design: .rounded)
            case .small:
                return .system(size: 20, design: .rounded)
            case .normal:
                return .system(size: 40, design: .rounded)
            case .medium:
                return .system(size: 70, design: .rounded)
            case .large:
                return .system(size: 110, design: .rounded)
        }
    }
}
