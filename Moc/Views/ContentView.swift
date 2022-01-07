//
//  ContentView.swift
//  Moc
//
//  Created by Егор Яковенко on 24.12.2021.
//

import SwiftUI
import TDLibKit
import Resolver

extension Chat: Identifiable {

}

struct ContentView: View {
    @State private var selectedFolder: Int = 0
    @State private var selectedChat: Int? = 0
    @StateObject private var mainViewModel = MainViewModel()

    @Injected private var tdApi: TdApi

    @State private var showingLoginScreen = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    ScrollView(showsIndicators: false) {
                        ForEach(0..<10, content: { index in
                            FolderItemView()
                        }).frame(alignment: .center)
                    }
                    .frame(minWidth: 70)
                    VStack {
//                        SearchField()
//                            .padding([.leading, .bottom, .trailing], 10.0)
                        GeometryReader { proxy in
                            List(mainViewModel.chatList) { chat in
                                NavigationLink(tag: Int(chat.id), selection: $selectedChat) {
                                    GeometryReader { proxy in
                                        ChatView(chat: chat)
                                            .frame(width: proxy.size.width, height: proxy.size.height)
                                            .navigationTitle("")
                                    }
                                } label: {
                                    ChatItemView(chat: chat)
                                        .frame(height: 56)
                                }
                                //								NavigationLink(destination: {
                                //
                                //								}) {
                                //                                    ChatItemView(chat: chat)
                                //										.frame(height: 56)
                                //								}
                            }
                            .swipeActions {
                                Button(role: .destructive) { NSLog("Pressed Delete button") } label: {
                                    Label("Delete chat", systemImage: "trash")
                                }
                            }
                            .toolbar {
                                ToolbarItem(placement: .status) {
                                    Button(action: {

                                    }) {
                                        Image(systemName: "square.and.pencil")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .sheet(isPresented: $showingLoginScreen) {
            LoginView()
                .frame(width: 300, height: 400)
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateNewChat)) { data in
            NSLog("Received chat position update")
            let chat = (data.object as! UpdateNewChat).chat
            let hasChat = mainViewModel.chatList.contains(where: {
                $0.id == chat.id
            })

            if !hasChat {
                mainViewModel.chatList.append(chat)
            }

            mainViewModel.chatList = mainViewModel.chatList.sorted(by: {
                if !$0.positions.isEmpty && !$1.positions.isEmpty {
                    return $0.positions[0].order.rawValue > $1.positions[0].order.rawValue
                } else {
                    return true
                }
            })

        }
        .onReceive(NotificationCenter.default.publisher(for: .authorizationStateWaitPhoneNumber)) { data in
            NSLog("Phone number update lol")
            showingLoginScreen = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
