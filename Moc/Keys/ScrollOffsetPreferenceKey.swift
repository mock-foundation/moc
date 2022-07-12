//
//  ScrollOffsetPreferenceKey.swift
//  Moc
//
//  Created by Егор Яковенко on 12.07.2022.
//

import Foundation
import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: Int = 0
    
    static func reduce(value: inout Int, nextValue: () -> Int) {
        value = nextValue()
    }
}
