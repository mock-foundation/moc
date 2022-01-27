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
        // colors[[0, 7, 4, 1, 6, 3, 5][id % 7]]

        self.init(nsColor: NSColor(colors[[0, 7, 4, 1, 6, 3, 5][id % 7]]))
    }
}
