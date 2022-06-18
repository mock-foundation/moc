//
//  MessageView.swift
//  Moc
//
//  Created by Егор Яковенко on 26.02.2022.
//

import SwiftUI

struct MessageView: View {
    @State var message: Moc.Message

    @ViewBuilder
    var body: some View {
        switch message.content {
            case let .messageText(info):
                MessageBubbleView(sender: message.sender.name, isOutgoing: message.isOutgoing) {
                    Text(info.text.text)
                        .textSelection(.enabled)
                        .if(message.isOutgoing) { view in
                            view.foregroundColor(.white)
                        }
                    
                }
            case let .messagePhoto(info):
                MessageBubbleView(sender: message.sender.name, isOutgoing: message.isOutgoing) {
                    VStack {
                        if info.photo.sizes.isEmpty == false {
                            AsyncTdImage(id: info.photo.sizes[info.photo.sizes.endIndex - 1].photo.id) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                        Text(info.caption.text)
                            .if(message.isOutgoing) { view in
                                view.foregroundColor(.white)
                            }
                            .multilineTextAlignment(.leading)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                }
            case .messageUnsupported:
                MessageBubbleView(sender: message.sender.name, isOutgoing: message.isOutgoing) {
                    Text("Sorry, this message is unsupported.")
                        .if(message.isOutgoing) { view in
                            view.foregroundColor(.white)
                        }
                }
            default:
                MessageBubbleView(sender: message.sender.name, isOutgoing: message.isOutgoing) {
                    Text("Sorry, this message is unsupported.")
                        .if(message.isOutgoing) { view in
                            view.foregroundColor(.white)
                        }
                }
        }
    }
}
