//
//  MessageView+Reply.swift
//  Moc
//
//  Created by Егор Яковенко on 04.07.2022.
//

import SwiftUI
import TDLibKit
import Utilities

extension MessageView {
    @ViewBuilder
    var replyView: some View {
        if let reply = message.first!.replyToMessage {
            Button {
                SystemUtils.post(notification: .scrollToMessage, with: reply.id)
            } label: {
                HStack {
                    Capsule()
                        .if(mainMessage.isOutgoing) {
                            $0.fill(.white)
                        }
                        .frame(width: 3)
                    VStack(alignment: .leading) {
                        Text(reply.sender)
                            .if(mainMessage.isOutgoing) {
                                $0.foregroundColor(.white)
                            }
                        reply.content.preview
                            .if(mainMessage.isOutgoing) {
                                $0.foregroundColor(.white.darker(by: 50))
                            }
                            .if(!mainMessage.isOutgoing) {
                                $0.foregroundStyle(.secondary)
                            }
                    }
                }
            }
            .buttonStyle(.plain)
            .frame(height: 30)
        }
    }
}
