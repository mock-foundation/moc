//
//  MessageBubbleView.swift
//  Moc
//
//  Created by Егор Яковенко on 29.12.2021.
//

import SwiftUI

struct MessageBubbleView<Content: View>: View {
    @State var isOutgoing: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
        .if(!isOutgoing) {
            $0.padding(.leading, 7)
        }
        .background {
            if isOutgoing {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .foregroundColor(Color("MessageFromMeColor"))
            } else {
                Image("ChatMessageBubbleRecipient")
                    .resizable(capInsets: EdgeInsets(
                        top: 18,
                        leading: 18,
                        bottom: 18,
                        trailing: 18
                    ), resizingMode: .stretch)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .foregroundColor(Color("MessageFromRecepientColor"))
            }
        }
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubbleView {
            Text("u just wOt?")
                .padding()
        }
        
        MessageBubbleView(isOutgoing: true) {
            Text("u just wOt?")
                .padding()
        }
    }
}
