//
//  View+If.swift
//  Moc
//
//  Created by Егор Яковенко on 24.05.2022.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        }
    }
}
