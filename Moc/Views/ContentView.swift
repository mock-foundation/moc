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
import Caching
import Introspect

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
    @State private var searchText = ""
    
    #if os(iOS)
    @State private var areSettingsOpen = false
    #endif

    @InjectedObject private var chatViewModel: ChatViewModel

    @InjectedObject private var mainViewModel: MainViewModel
    @StateObject private var viewRouter = ViewRouter()
    
    private var chatList: some View {
        ScrollView {
            LazyVStack {
                ForEach(mainViewModel.chatList) { chat in
                    Button {
                        Task {
                            do {
                                try await chatViewModel.update(chat: chat)
                            } catch {
                                logger.error("Error in \(error.localizedDescription)")
                            }
                        }
                        viewRouter.openedChat = chat
                        viewRouter.currentView = .chat
                    } label: {
                        ChatItemView(chat: chat)
                            .frame(height: 52)
                            .padding(6)
                            .background(
                                (viewRouter.currentView == .chat
                                 && viewRouter.openedChat! == chat)
                                ? Color.accentColor.opacity(0.6)
                                : nil
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }.buttonStyle(.plain)
                }
            }
            #if os(macOS)
            .padding(.trailing, 12)
            #elseif os(iOS)
            .padding(8)
            #endif
        }
    }
    
    private var chatListToolbar: some ToolbarContent {
        #if os(macOS)
        let placement: ToolbarItemPlacement = .status
        #elseif os(iOS)
        let placement: ToolbarItemPlacement = .navigationBarLeading
        #endif
        return Group {
            #if os(macOS)
            ToolbarItem(placement: placement) {
                Picker("", selection: $selectedTab) {
                    Image(systemName: "bubble.left.and.bubble.right").tag(Tab.chat)
                    Image(systemName: "phone.and.waveform").tag(Tab.calls)
                    Image(systemName: "person.2").tag(Tab.contacts)
                }.pickerStyle(.segmented)
            }
            #endif
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
    
    private func makeFolderItem(
        name: String,
        icon: Image,
        unreadCount: Int,
        chatList: Caching.ChatList,
        horizontal: Bool
    ) -> some View {
        Button {
            mainViewModel.openChatList = chatList
        } label: {
            FolderItemView(
                name: name,
                icon: icon,
                unreadCount: unreadCount,
                horizontal: horizontal)
            .background(mainViewModel.openChatList == chatList
                        ? Color("SelectedColor") : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        #if os(iOS)
        .hoverEffect(mainViewModel.openChatList == chatList ? .lift : .highlight)
        #endif
    }
    
    @ViewBuilder
    private func makeFolders(horizontal: Bool) -> some View {
        makeFolderItem(
            name: "All Chats",
            icon: Image(systemName: "bubble.left.and.bubble.right"),
            unreadCount: mainViewModel.mainUnreadCounter,
            chatList: .main,
            horizontal: horizontal)
        ForEach(mainViewModel.folders) { folder in
            makeFolderItem(
                name: folder.title,
                icon: Image(tdIcon: folder.iconName),
                unreadCount: folder.unreadCounter,
                chatList: .filter(folder.id),
                horizontal: horizontal)
        }
    }
        
    @ViewBuilder
    private var filterBar: some View {
        #if os(macOS)
        let orientation: Axis.Set = .vertical
        #elseif os(iOS)
        let orientation: Axis.Set = .horizontal
        #endif
        ScrollView(orientation, showsIndicators: false) {
            Group {
                switch selectedTab {
                    case .chat:
                        #if os(macOS)
                        makeFolders(horizontal: false)
                        #elseif os(iOS)
                        HStack {
                            makeFolders(horizontal: true)
                        }
                        #endif
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
            #if os(macOS)
            .padding(.bottom)
            #elseif os(iOS)
            .padding(8)
            #endif
        }
        #if os(macOS)
        .frame(width: 90)
        #elseif os(iOS)
        .background(.bar, in: Rectangle())
        #endif
    }
    
    private var chats: some View {
        VStack {
            #if os(macOS)
            SearchField()
                .controlSize(.large)
                .padding(.trailing, 12)
            #endif
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
            .frame(maxHeight: .infinity)
            #if os(iOS)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            #endif
        }
        .toolbar {
            chatListToolbar
        }
    }
    
    #if os(iOS)
    @ViewBuilder
    private func makeTabBarButton(
        _ title: String,
        systemImage: String,
        value: Tab
    ) -> some View {
        Button {
            selectedTab = value
        } label: {
            makeTabBarItem(title, systemImage: systemImage)
        }
        .buttonStyle(.plain)
        .foregroundColor(selectedTab == value ? .blue : Color(uiColor: .darkGray))
        Spacer()
    }
    
    private func makeTabBarItem(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .labelStyle(TabLabelStyle())
    }
    #endif
    
    private var sidebar: some View {
        #if os(macOS)
        HStack {
            filterBar
            chats
        }
        .frame(minWidth: 400)
        #elseif os(iOS)
        chats
            .safeAreaInset(edge: .top) {
                if !mainViewModel.isArchiveOpen {
                    filterBar
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    makeTabBarButton("Contacts", systemImage: "person.2.fill", value: .contacts)
                    makeTabBarButton("Calls", systemImage: "phone.and.waveform.fill", value: .calls)
                    makeTabBarButton("Chats", systemImage: "bubble.left.and.bubble.right.fill", value: .chat)
                    Menu {
                        Button { areSettingsOpen = true } label: { Label("Settings", systemImage: "gear") }
                        Divider()
                        Button { } label: { Label("Moc Updates", systemImage: "newspaper") }
                        Button { } label: { Label("Telegram Tips", systemImage: "text.book.closed") }
                        Button { } label: { Label("Find people nearby", systemImage: "person.wave.2") }
                        Button { } label: { Label("Saved messages", systemImage: "bookmark") }
                    } label: {
                        makeTabBarItem("More", systemImage: "ellipsis")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(Color(uiColor: .darkGray))
                    Spacer()
                }
                .padding(.vertical)
                .background(.ultraThinMaterial, in: Rectangle())
            }
        #endif
    }

    var body: some View {
        Group {
//            if #available(macOS 13, iOS 16, *) {
//                NavigationSplitView {
//                    sidebar
//                } detail: {
//                    switch viewRouter.currentView {
//                        case .selectChat:
//                            chatPlaceholder
//                        case .chat:
//                            ChatView()
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    }
//                }
//            } else {
                NavigationView {
                    sidebar
                    .listStyle(.sidebar)
                    
                    switch viewRouter.currentView {
                        case .selectChat:
                            chatPlaceholder
                        case .chat:
                            ChatView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            // TODO: Implement vertical folders
                #if os(iOS)
                .introspectNavigationController { navigationController in
                    navigationController.splitViewController?.preferredPrimaryColumnWidthFraction = 1
                    navigationController.splitViewController?.maximumPrimaryColumnWidth = 350.0
                }
                #endif
//            }
        }
        .sheet(isPresented: $mainViewModel.showingLoginScreen) {
            LoginView()
                .frame(width: 400, height: 500)
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $areSettingsOpen) {
            SettingsContent()
        }
        #endif
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
