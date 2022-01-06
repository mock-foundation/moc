//
//  ChatView.swift
//  Moc
//
//  Created by Егор Яковенко on 28.12.2021.
//

import SwiftUI
import TDLibKit

struct ChatView: View {
    @State var chat: Chat
	@State private var inputMessage = ""
	@Environment(\.colorScheme) var colorScheme
	
	private var inputField: some View {
		HStack(spacing: 16) {
			Image(systemName: "paperclip")
				.font(.system(size: 16))
			TextField("Write a message...", text: $inputMessage)
				.textFieldStyle(.plain)
				.padding(6)
				.padding(.horizontal, 8)
				.background(RoundedRectangle(cornerRadius: 16).stroke(Color("InputFieldBorderColor"), lineWidth: 1))
			Image(systemName: "face.smiling")
				.font(.system(size: 16))
			Image(systemName: "mic")
				.font(.system(size: 16))
		}
	}
	
	var body: some View {
		VStack {
			ScrollViewReader { proxy in
				ScrollView {
					ForEach(0..<50) { _ in
						HStack {
							MessageBubbleView()
								.frame(width: 300)
							Spacer()
						}
					}
				}
				.onAppear {
					proxy.scrollTo(50 - 1)
				}
			}
			inputField
				.padding()
		}
	}
}

//struct ChatView_Previews: PreviewProvider {
//	static var previews: some View {
//		ChatView()
//	}
//}
