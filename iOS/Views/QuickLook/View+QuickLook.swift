//
//  View+QuickLook.swift
//  Moc
//
//  Created by Егор Яковенко on 21.06.2022.
//

import SwiftUI

public extension View {
    func quickLookPreview(
        _ items: Binding<[QuickLookPreviewItem]>,
        at index: Binding<Int> = .constant(0)
    ) -> some View {
        background {
            if !items.isEmpty {
                QuickLookPreviewWrapper(items: items, index: index)
            }
        }
    }
}
