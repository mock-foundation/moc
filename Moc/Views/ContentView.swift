//
//  ContentView.swift
//  Moc
//
//  Created by Егор Яковенко on 24.12.2021.
//

import SwiftUI
import TDLibKit
import Resolver
import Logging
import SystemUtils

extension Chat: Identifiable { }

struct ContentView: View {
    private let logger = Logging.Logger(label: "ContentView")

    @State private var selectedFolder: Int = 0
    @State private var selectedChat: Int? = 0
    @State private var showingLoginScreen = false

    @StateObject private var mainViewModel = MainViewModel()
    @StateObject private var viewRouter = ViewRouter()

    @Injected private var tdApi: TdApi

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    ScrollView(showsIndicators: false) {
                        ForEach(0..<10, content: { _ in
                            FolderItemView()
                        }).frame(alignment: .center)
                    }
                    .frame(minWidth: 70)
                    VStack {
                        SearchField()
                            .padding([.leading, .bottom, .trailing], 10.0)
                        List(mainViewModel.chatList) { chat in
                            ChatItemView(chat: chat)
                                .frame(height: 52)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) { logger.info("Pressed Delete button") } label: {
                                        Label("Delete chat", systemImage: "trash")
                                    }
                                }
                                .onTapGesture {
                                    viewRouter.openedChat = chat
                                    viewRouter.currentView = .chat
                                }
                                .padding(6)
                                .background(
                                    (viewRouter.currentView == .chat
                                     && viewRouter.openedChat! == chat)
                                    ? Color.blue.opacity(0.8)
                                    : nil
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }.toolbar {
                        ToolbarItem(placement: .status) {
                            Button(action: { print("add chat") }) {
                                Image(systemName: "square.and.pencil")
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)

            switch viewRouter.currentView {
                case .selectChat:
                    VStack {
                        Text("Select chat")
                    }
                case .chat:
                    VStack {
                        ChatView(chat: viewRouter.openedChat!)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
            }
        }
        .sheet(isPresented: $showingLoginScreen) {
            LoginView()
                .frame(width: 400, height: 500)
        }
        .onReceive(SystemUtils.ncPublisher(for: .updateNewMessage)) { notification in
            let message = (notification.object as? UpdateNewMessage)!.message

            guard viewRouter.openedChat != nil else { return }

//            if message.chatId == viewRouter.openedChat!.id {
//                chatViewModel.messages?.append(message)
//            }
        }
        .onReceive(SystemUtils.ncPublisher(for: .updateNewChat)) { data in
            logger.info("Received new chat update")
            guard data.object != nil else {
                return
            }
            let chat = (data.object as? UpdateNewChat)!.chat

            let hasChat = mainViewModel.chatList.contains(where: {
                $0.id == chat.id
            })

            logger.info("\(chat)")

            var isInMainChatList: Bool {
                for position in chat.positions {
                    if position.list == .chatListMain {
                        logger.info("In main chat list")
                        if !hasChat {
                            mainViewModel.chatList.append(chat)
                        }
                        return true
                    } else {
                        logger.warning("Not in main chat list")
                        return false
                    }
                }
                logger.warning("Chat positions empty")
                return false
            }

            mainViewModel.chatList = mainViewModel.chatList.sorted(by: {
//                if !$0.positions.isEmpty && !$1.positions.isEmpty {
//                    return $0.positions[0].order.rawValue > $1.positions[0].order.rawValue
//                } else {
//                    return true
//                }
                                if $0.lastMessage?.date ?? 1 > $1.lastMessage?.date ?? 0 {
                                    return true
                                } else {
                                    return false
                                }
            })

        }
        .onReceive(SystemUtils.ncPublisher(for: .authorizationStateWaitPhoneNumber)) { _ in
            showingLoginScreen = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
