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
import Backend

extension Chat: Identifiable { }

struct ContentView<T: ChatDataSource>: View {
    private let logger = Logging.Logger(label: "ContentView")

    @State private var selectedFolder: Int = 0
    @State private var selectedChat: Int? = 0
    @State private var isArchiveChatListOpen = false
    @State private var showingLoginScreen = false

    @Injected private var chatDataSource: T

    @StateObject private var mainViewModel = MainViewModel()
    @StateObject private var viewRouter = ViewRouter()

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
                            .padding([.leading, .bottom, .trailing], 15.0)
                        List(mainViewModel.mainChatList) { chat in
                            ChatItemView(chat: chat)
                                .frame(height: 52)
                                .onTapGesture {
                                    chatDataSource.setChat(chat)
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
                                .swipeActions {
                                    Button(role: .destructive) {
                                        logger.info("Pressed Delete button")
                                    } label: {
                                        Label("Delete chat", systemImage: "trash")
                                    }
                                }
                        }
                        .frame(minWidth: 320)
                    }.toolbar {
                        ToolbarItem(placement: .status) {
                            Toggle(isOn: $isArchiveChatListOpen) {
                                Image(systemName: isArchiveChatListOpen ? "archivebox.fill" : "archivebox")
                            }
                        }
                        ToolbarItem(placement: .status) {
                            Spacer()
                        }
                        ToolbarItem(placement: .status) {
                            Button(action: { logger.info("Pressed add chat") }) {
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
                    ChatView<TdChatDataSource>()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showingLoginScreen) {
            LoginView<TdLoginDataSource>()
                .frame(width: 400, height: 500)
        }
        .onReceive(SystemUtils.ncPublisher(for: .updateChatPosition)) { notification in
            logger.info("Update chat position")
            let update = (notification.object as? UpdateChatPosition)!
            let position = update.position
            let chatId = update.chatId

            if mainViewModel.unorderedChatList.contains(where: { $0.id == chatId }) {
                switch position.list {
                    case .chatListMain:
                        let chats = mainViewModel.unorderedChatList.filter { chat in
                            return chat.id == chatId
                        }
                        for chat in chats {
                            mainViewModel.mainChatList.append(chat)
                        }
                        mainViewModel.unorderedChatList = mainViewModel.unorderedChatList.filter {
                            return $0.id != chatId
                        }
                        sortMainChatList()
                    case .chatListArchive:
                        break
                    case .chatListFilter(_):
                        break
                }
            }
        }
        .onReceive(SystemUtils.ncPublisher(for: .updateNewChat)) { data in
            logger.info("Received new chat update")
            guard data.object != nil else {
                return
            }
            let chat = (data.object as? UpdateNewChat)!.chat

            let hasChat = mainViewModel.unorderedChatList.contains(where: {
                $0.id == chat.id
            })

            if !hasChat {
                mainViewModel.unorderedChatList.append(chat)
            }

            logger.info("\(chat)")

            sortMainChatList()

        }
        .onReceive(SystemUtils.ncPublisher(for: .authorizationStateWaitPhoneNumber)) { _ in
            showingLoginScreen = true
        }
    }

    private func sortMainChatList() {
        mainViewModel.mainChatList = mainViewModel.mainChatList.sorted {
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView<MockChatDataSource>()
    }
}
