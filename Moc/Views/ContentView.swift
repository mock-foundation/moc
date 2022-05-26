//
//  ContentView.swift
//  Moc
//
//  Created by Егор Яковенко on 24.12.2021.
//

import Backend
import Logs
import Resolver
import SwiftUI
import Utilities
import TDLibKit

private enum Tab {
    case chat
    case contacts
    case calls
}

struct ContentView: View {
    private let logger = Logs.Logger(label: "UI", category: "ContentView")

    @State private var selectedFolder: Int = 0
    @State private var selectedChat: Int? = 0
    @State private var isArchiveChatListOpen = false
    @State private var selectedTab: Tab = .chat

    @InjectedObject private var chatViewModel: ChatViewModel

    @InjectedObject private var mainViewModel: MainViewModel
    @StateObject private var viewRouter = ViewRouter()

    init() {
        mainViewModel.registerSubscriptions()
    }
    
    private func makeChatList(_ list: [Chat]) -> some View {
        ScrollView {
            LazyVStack {
                ForEach(list) { chat in
                    ChatItemView(chat: chat)
                        .frame(height: 52)
                        .onTapGesture {
                            Task {
                                do {
                                    try await chatViewModel.update(chat: chat)
                                } catch {
                                    logger.error("Error in \(error.localizedDescription)")
                                }
                            }
                            viewRouter.openedChat = chat
                            viewRouter.currentView = .chat
                        }
                        .padding(6)
                        .background(
                            (viewRouter.currentView == .chat
                             && viewRouter.openedChat! == chat)
                            ? Color.accentColor.opacity(0.6)
                            : nil
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
    }
    
    private var chatListToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .status) {
                Picker("", selection: $selectedTab) {
                    Image(systemName: "bubble.left.and.bubble.right").tag(Tab.chat)
                    Image(systemName: "phone.and.waveform").tag(Tab.calls)
                    Image(systemName: "person.2").tag(Tab.contacts)
                }.pickerStyle(.segmented)
            }
            ToolbarItem(placement: .status) {
                Spacer()
            }
            ToolbarItem(placement: .status) {
                Toggle(isOn: $isArchiveChatListOpen) {
                    Image(systemName: isArchiveChatListOpen ? "archivebox.fill" : "archivebox")
                }
            }
            ToolbarItem(placement: .status) {
                // swiftlint:disable multiple_closures_with_trailing_closure
                Button(action: { logger.info("Pressed add chat") }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }
    
    private var filterBar: some View {
        ScrollView(showsIndicators: false) {
            Group {
                switch selectedTab {
                    case .chat:
                        ForEach(0 ..< 10, content: { _ in
                            FolderItemView()
                        })
                    case .contacts:
                        Image(systemName: "person.2")
                    case .calls:
                        Image(systemName: "phone.and.waveform")
                }
            }.frame(alignment: .center)
        }
        .frame(width: 90)
    }
    
    private var chatList: some View {
        VStack {
            SearchField()
                .controlSize(.large)
            //                            .padding([.trailing, .bottom], 8)
            Group {
                switch selectedTab {
                    case .chat:
                        isArchiveChatListOpen
                        ? makeChatList(mainViewModel.archiveChatList)
                        : makeChatList(mainViewModel.mainChatList)
                    case .contacts:
                        Text("Contacts")
                    case .calls:
                        Text("Calls")
                }
            }
            .frame(minWidth: 300, maxHeight: .infinity)
        }
        .padding(.trailing, 8)
        .toolbar {
            chatListToolbar
        }
    }

    var body: some View {
        NavigationView {
            HStack {
                filterBar
                chatList
            }
            .listStyle(.sidebar)

            switch viewRouter.currentView {
            case .selectChat:
                chatPlaceholder
            case .chat:
                ChatView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $mainViewModel.showingLoginScreen) {
            LoginView()
                .frame(width: 400, height: 500)
        }
    }

    private var chatPlaceholder: some View {
        VStack {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 96))
                .foregroundColor(.gray)
            Text("Open a chat or start a new one!")
                .font(.largeTitle)
                .foregroundStyle(Color.secondary)
            Text("Pick any chat on the left sidebar, and have fun chatting!")
                .foregroundStyle(Color.secondary)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
