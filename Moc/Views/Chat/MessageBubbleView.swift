//
//  MessageBubbleView.swift
//  Moc
//
//  Created by Егор Яковенко on 29.12.2021.
//

import SwiftUI

struct MessageBubbleView: View {
	var body: some View {
		ZStack {
			// Background
			Image("ChatMessageBubbleRecipient")
				.resizable(capInsets: EdgeInsets(top: 18, leading: 18, bottom: 18, trailing: 18), resizingMode: .stretch)
				.foregroundColor(Color("MessageFromRecepientColor"))

			// Content
            HStack {
                Image("MockChatPhoto")
                    .frame(width: 24, height: 24)
                VStack(alignment: .leading) {
                    Text("Sender")
                        .foregroundColor(.blue)
                    Text("Message content")
                        .lineLimit(50)
                }
            }
			.padding(.leading)
			.padding([.bottom, .top, .trailing], 6)
		}
	}
}

struct MessageBubble_Previews: PreviewProvider {
	static var previews: some View {
		MessageBubbleView()
			.preferredColorScheme(.dark)
			.frame(height: 40.0)
	}
}
