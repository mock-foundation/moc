//
//  MessageView+Bubble.swift
//  Moc
//
//  Created by Егор Яковенко on 21.06.2022.
//

import SwiftUI

extension MessageView {
    func makeMessageBubble<Content: View>(
        isOutgoing: Bool = false,
        @ViewBuilder _ content: @escaping () -> Content
    ) -> some View {
        content()
            .if(!isOutgoing) {
                $0.padding(.leading, 7)
            }
            .background {
                if isOutgoing {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .foregroundColor(Color("MessageFromMeColor"))
                } else {
                    MessageBubbleShape()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .foregroundColor(Color("MessageFromRecepientColor"))
                }
            }
    }
}
