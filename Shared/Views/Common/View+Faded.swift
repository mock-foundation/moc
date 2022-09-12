//
//  View+Faded.swift
//  Moc
//
//  Created by Егор Яковенко on 09.09.2022.
//

import SwiftUI

extension View {
    func faded(top: Bool, bottom: Bool) -> some View {
        self.mask {
            VStack(spacing: 0) {
                if top {
                    Rectangle()
                        .fill(.linearGradient(colors: [.white.opacity(0), .white], startPoint: .top, endPoint: .bottom))
                        .frame(height: 30)
                        .transition(.move(edge: .top))
                }
                Rectangle()
                if bottom {
                    Rectangle()
                        .fill(.linearGradient(colors: [.white.opacity(0), .white], startPoint: .bottom, endPoint: .top))
                        .frame(height: 30)
                        .transition(.move(edge: .bottom))
                }
            }
            .animation(.fastStartSlowStop(0.4), value: top)
            .animation(.fastStartSlowStop(0.4), value: bottom)
        }
    }
}
