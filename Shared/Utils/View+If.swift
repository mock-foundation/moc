//
//  View+If.swift
//  Moc
//
//  Created by Егор Яковенко on 24.05.2022.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        transform: (Self) -> TrueContent,
        else elseTransform: ((Self) -> FalseContent)? = nil
    ) -> some View {
        if condition {
            transform(self)
        } else {
            if let elseTransform {
                elseTransform(self)
            } else {
                self
            }
        }
    }
    
    @ViewBuilder func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
