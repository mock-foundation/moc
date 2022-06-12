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
import OrderedCollections

private enum Tab {
    case chat
    case contacts
    case calls
}

struct ContentView: View {
    private let logger = Logs.Logger(label: "UI", category: "ContentView")

    @State private var selectedFolder: Int = 0
    @State private var selectedChat: Int? = 0
    @State private var selectedTab: Tab = .chat

    @InjectedObject private var chatViewModel: ChatViewModel

    @InjectedObject private var mainViewModel: MainViewModel
    @StateObject private var viewRouter = ViewRouter()
    
    private var chatList: some View {
        ScrollView {
            LazyVStack {
                ForEach(mainViewModel.chatList) { chat in
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
            }.padding(.trailing, 12)
        }
    }
    
    private var chatListToolbar: some ToolbarContent {
        #if os(macOS)
        let placement: ToolbarItemPlacement = .status
        #elseif os(iOS)
        let placement: ToolbarItemPlacement = .navigationBarLeading
        #endif
        return Group {
            ToolbarItem(placement: placement) {
                Picker("", selection: $selectedTab) {
                    Image(systemName: "bubble.left.and.bubble.right").tag(Tab.chat)
                    Image(systemName: "phone.and.waveform").tag(Tab.calls)
                    Image(systemName: "person.2").tag(Tab.contacts)
                }.pickerStyle(.segmented)
            }
            ToolbarItem(placement: placement) {
                Spacer()
            }
            ToolbarItem(placement: placement) {
                Toggle(isOn: $mainViewModel.isArchiveOpen) {
                    Image(systemName: mainViewModel.isArchiveOpen ? "archivebox.fill" : "archivebox")
                }
            }
            ToolbarItem(placement: placement) {
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
                        FolderItemView(
                            name: "All chats",
                            icon: Image(systemName: "bubble.left.and.bubble.right"),
                            unreadCount: mainViewModel.mainUnreadCounter)
                            .background(mainViewModel.openChatList == .main
                                        ? Color("SelectedColor") : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .onTapGesture {
                                mainViewModel.openChatList = .main
                            }
                        ForEach(mainViewModel.folders) { folder in
                            FolderItemView(
                                name: folder.title,
                                icon: Image(tdIcon: folder.iconName),
                                unreadCount: folder.unreadCounter)
                            .background(mainViewModel.openChatList == .filter(folder.id)
                                        ? Color("SelectedColor") : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .onTapGesture {
                                mainViewModel.openChatList = .filter(folder.id)
                            }
                        }
                    case .contacts:
                        FolderItemView(name: "Nearby chats", icon: Image(systemName: "map"))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        FolderItemView(name: "Invite", icon: Image(systemName: "person.badge.plus"))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    case .calls:
                        FolderItemView(name: "Ingoing", icon: Image(systemName: "phone.arrow.down.left")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.green, .primary))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        FolderItemView(name: "Outgoing", icon: Image(systemName: "phone.arrow.up.right"))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        FolderItemView(name: "Missed", icon: Image(systemName: "phone.arrow.down.left")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.red, .primary))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .frame(alignment: .center)
            .padding(.bottom)
        }
        .frame(width: 90)
    }
    
    private var chats: some View {
        VStack {
            SearchField()
                .controlSize(.large)
                .padding(.trailing, 12)
            Group {
                switch selectedTab {
                    case .chat:
                        chatList
                    case .contacts:
                        Text("Contacts")
                    case .calls:
                        Text("Calls")
                }
            }
            .frame(minWidth: 300, maxHeight: .infinity)
        }
        .toolbar {
            chatListToolbar
        }
    }

    var body: some View {
        NavigationView {
            HStack {
                filterBar
                chats
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
    init() {
        Resolver.register { MockChatService() as ChatService }
        Resolver.register { MockMainService() as MainService }
    }
    
    static var previews: some View {
        ContentView()
    }
}
