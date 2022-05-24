//
//  MessageView.swift
//  Moc
//
//  Created by Егор Яковенко on 26.02.2022.
//

import SwiftUI

struct MessageView: View {
    @State var message: Moc.Message

    var body: some View {
        switch message.content {
            case .text(let text):
                MessageBubbleView(sender: message.sender.name, isOutgoing: message.isOutgoing) {
                    Text(text.text.text)
                }
            case .unsupported:
                MessageBubbleView(sender: message.sender.name, isOutgoing: message.isOutgoing) {
                    Text("Sorry, this message is unsupported.")
                }
        }
    }
}
