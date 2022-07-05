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
                    Group {
                        switch reply.content {
                            case let .messageText(info):
                                Text(info.text.text)
                            default:
                                Text(unsupportedMessageString)
                        }
                    }
                    .if(mainMessage.isOutgoing) {
                        $0.foregroundColor(.white.darker(by: 50))
                    }
                    .if(!mainMessage.isOutgoing) {
                        $0.foregroundStyle(.secondary)
                    }
                }
            }
            .frame(height: 30)
        }
    }
}
