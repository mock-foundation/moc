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
        transform: (Self) -> Content,
        else elseTransform: ((Self) -> Content)? = nil
    ) -> some View {
        if condition {
            transform(self)
        } else {
            if elseTransform != nil {
                elseTransform!(self)
            } else {
                self
            }
        }
    }
}
