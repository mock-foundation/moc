//
//  ChatView.swift
//  Moc
//
//  Created by Егор Яковенко on 28.12.2021.
//

import SwiftUI
import TDLibKit

struct ChatView: View {
    let chat: Chat
    @State private var inputMessage = ""
    @State private var isInspectorShown = true
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Input field
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

    // MARK: - Chat view
    private var chatView: some View {
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

    // MARK: - Chat inspector
    private var chatInspector: some View {
    }

    var body: some View {
        SplitView(leftView: {
            chatView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }, rightView: {
            chatInspector
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }, isRightViewVisible: isInspectorShown)
            .navigationTitle("")
            // MARK: - Toolbar
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Image("MockChatPhoto")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                }
                ToolbarItem(placement: .navigation) {
                    VStack(alignment: .leading) {
                        Text(chat.title)
                        // Text("Chat title")
                            .font(.headline)
//                        Text("Some users were here lol")
//                            .font(.subheadline)
                        ProgressView()
                            .progressViewStyle(.linear)
                    }
                }
                ToolbarItemGroup {
                    Button(action: {
                        print("search")
                    }, label: {
                        Image(systemName: "magnifyingglass")
                    })
                    Button(action: { isInspectorShown.toggle() }, label: {
                        Image(systemName: "sidebar.right")
                    })
                    Button(action: {
                        print("more")
                    }, label: {
                        Image(systemName: "ellipsis")
                    })
                }
            }
    }
}

//struct ChatView_Previews: PreviewProvider {
//	static var previews: some View {
//		ChatView()
//	}
//}
