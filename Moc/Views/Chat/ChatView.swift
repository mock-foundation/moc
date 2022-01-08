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

    private func InspectorButton(action: @escaping () -> Void, imageName: String, text: String) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: imageName)
                    .font(.system(size: 24))
                Text(text)
            }
        }
        .frame(width: 56, height: 56)
        .buttonStyle(.borderless)
    }

    // MARK: - Chat inspector
    private var chatInspector: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image("MockChatPhoto")
                    .resizable()
                    .frame(minWidth: 0, maxWidth: 86, minHeight: 0, maxHeight: 86)
                    .clipShape(Circle())
                Text(chat.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .frame(minWidth: 0, idealWidth: nil)
                Text("a ton of members")
                // Button row
                HStack(spacing: 24) {
                    InspectorButton(
                        action: {
                            print("Ayy")
                        },
                        imageName: "person.crop.circle.badge.plus",
                        text: "Add"
                    )
                    InspectorButton(
                        action: {
                            print("Ayy x2")
                        },
                        imageName: "bell.slash",
                        text: "Mute"
                    )
                    InspectorButton(
                        action: {
                            print("Ayy x3")
                        },
                        imageName: "arrow.turn.up.right",
                        text: "Leave"
                    )
                }
                .padding(.vertical)
                .frame(minWidth: 0, idealWidth: nil)
            }
            .padding(.top)
        }
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
