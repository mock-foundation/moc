//
//  MessageBubbleView.swift
//  Moc
//
//  Created by Егор Яковенко on 29.12.2021.
//

import SwiftUI

struct MessageBubbleView<Content: View>: View {
    @State var sender: String
    @State var isOutgoing: Bool = false
    @State var content: () -> Content

    var body: some View {
//            Image("MockChatPhoto")
//                .resizable()
//                .frame(width: 36, height: 36)
//                .clipShape(Circle())
//                .padding(.leading, 8)
//                .vBottom()
        VStack(alignment: .leading) {
            if !isOutgoing {
                Text(sender)
                    .foregroundColor(.blue)
            }
            content()
        }
        .if(!isOutgoing) {
            $0.padding(.leading, 8)
        }
        .padding(8)
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
        MessageBubbleView(sender: "Me") {
            Text("u just wOt?")
        }
        .preferredColorScheme(.dark)
//        .frame(height: 40.0)
        
        MessageBubbleView(sender: "Me", isOutgoing: true) {
            Text("u just wOt?")
        }
        .preferredColorScheme(.dark)
//        .frame(height: 40.0)
    }
}
