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
import Defaults

private enum Tab {
    case chat
    case contacts
    case calls
}

// swiftlint:disable type_body_length
struct ContentView: View {
    private let logger = Logs.Logger(category: "ContentView", label: "UI")

    @State private var selectedFolder: Int = 0
    @State private var selectedChat: Int? = 0
    @State private var selectedTab: Tab = .chat
    @State private var searchText = ""
    @Default(.folderLayout) private var folderLayout
    
    #if os(iOS)
    @State private var areSettingsOpen = false
    #endif

    @InjectedObject private var chatViewModel: ChatViewModel
    @InjectedObject private var mainViewModel: MainViewModel
    
    @StateObject private var viewRouter = ViewRouter()
    
    @Environment(\.colorScheme) var colorScheme
    
    private var chatList: some View {
        ScrollView {
            let stack = LazyVStack {
                ForEach(mainViewModel.chatList) { chat in
                    Button {
                        Task {
                            do {
                                try await chatViewModel.update(chat: chat)
                                _ = try await TdApi.shared[0].openChat(chatId: chat.id)
                                if let openedChat = viewRouter.openedChat {
                                    _ = try await TdApi.shared[0].closeChat(chatId: openedChat.id)
                                }
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
                                ? Color.accentColor.opacity(0.8)
                                : nil
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .environment(\.isChatListItemSelected, (viewRouter.currentView == .chat
                                                                    && viewRouter.openedChat! == chat))
                    }.buttonStyle(.plain)
                }
            }
            if folderLayout == .vertical {
                stack.padding(.trailing, 12)
            } else {
                stack.padding(8)
            }
        }
    }
    
    private var chatListToolbar: some ToolbarContent {
        #if os(macOS)
        let placement: ToolbarItemPlacement
        if #available(macOS 13, *) {
            placement = .automatic
        } else {
            placement = .status
        }
        #elseif os(iOS)
        let placement: ToolbarItemPlacement = .navigationBarLeading
        #endif
        return Group {
            #if os(macOS)
            ToolbarItemGroup(placement: placement) {
                if #unavailable(macOS 13) {
                    Button {
                        NSApp.keyWindow?.firstResponder?.tryToPerform(
                            #selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                    } label: {
                        Label("Toggle chat list", systemImage: "sidebar.left")
                    }
                }
                if mainViewModel.isChatListVisible {
                    Picker("", selection: $selectedTab) {
                        Image(systemName: "bubble.left.and.bubble.right").tag(Tab.chat)
                        Image(systemName: "phone.and.waveform").tag(Tab.calls)
                        Image(systemName: "person.2").tag(Tab.contacts)
                    }.pickerStyle(.segmented)
                }
            }
            #endif
            ToolbarItem(placement: placement) {
                Spacer()
            }
            ToolbarItemGroup(placement: placement) {
                if mainViewModel.isChatListVisible {
                    Toggle(isOn: $mainViewModel.isArchiveOpen) {
                        Image(systemName: mainViewModel.isArchiveOpen ? "archivebox.fill" : "archivebox")
                    }
                    Button {
                        logger.info("Pressed add chat")
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
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
        let scroll = ScrollView(folderLayout == .vertical ? .vertical : .horizontal, showsIndicators: false) {
            let group = Group {
                switch selectedTab {
                    case .chat:
                        if folderLayout == .vertical {
                            VStack {
                                makeFolders(horizontal: false)
                            }
                        } else {
                            HStack {
                                makeFolders(horizontal: true)
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
            if folderLayout == .vertical {
                group.padding(.bottom)
            } else {
                #if os(macOS)
                group
                #elseif os(iOS)
                group.padding(8)
                #endif
            }
        }
        if folderLayout == .vertical {
            scroll
                .frame(width: mainViewModel.sidebarSize == .small ? 75 : 90)
        } else {
            scroll
                #if os(iOS)
                .background(.bar, in: Rectangle())
                #endif
                .frame(minWidth: 0, maxWidth: .infinity)
            
        }
    }
    
    private var chats: some View {
        VStack {
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
        .hoverEffect()
        .foregroundColor(selectedTab == value ? .blue : (colorScheme == .dark ? .gray : Color(uiColor: .darkGray)))
        Spacer()
    }
    
    private func makeTabBarItem(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .labelStyle(TabLabelStyle())
    }
    #endif
    
    private var connectionState: some View {
        VStack {
            Spacer()
            HStack(spacing: 16) {
                Spacer()
                if !mainViewModel.isConnected {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .transition(.opacity)
                }
                Text(mainViewModel.connectionStateTitle)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer()
            }
            .padding()
        }
        #if os(macOS)
        .background(.linearGradient(
            Gradient(colors: [
                mainViewModel.isConnected
                ? .accentColor.opacity(0.7)
                : (colorScheme == .dark ? Color(nsColor: .darkGray) : .white),
                (colorScheme == .dark ? Color.black.opacity(0) : .white.opacity(0))]),
            startPoint: .bottom,
            endPoint: .top))
        #elseif os(iOS)
        .background(.linearGradient(
            Gradient(colors: [
                mainViewModel.isConnected
                ? .accentColor.opacity(0.7)
                : (colorScheme == .dark ? Color(uiColor: .darkGray) : .white),
                (colorScheme == .dark ? Color.black.opacity(0) : .white.opacity(0))]),
            startPoint: .bottom,
            endPoint: .top))
        #endif
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private var sidebar: some View {
        HStack {
            if folderLayout == .vertical {
                filterBar
                chats
                #if os(macOS)
                    .safeAreaInset(edge: .top) {
                        let field = SearchField()
                            .controlSize(.large)
                        if folderLayout == .vertical {
                            field.padding(.trailing, 12)
                        } else {
                            field.padding(.horizontal, 12)
                        }
                    }
                #endif
            } else {
                chats
                    #if os(macOS)
                    .safeAreaInset(edge: .top) {
                        let field = SearchField()
                            .controlSize(.large)
                        if folderLayout == .vertical {
                            field.padding(.trailing, 12)
                        } else {
                            field.padding(.horizontal, 12)
                        }
                    }
                    #endif
                    .safeAreaInset(edge: .top) {
                        if !mainViewModel.isArchiveOpen {
                            filterBar
                                #if os(macOS)
                                .padding(.horizontal)
                                #endif
                        }
                    }
            }
        }
        #if os(macOS)
        .frame(minWidth: folderLayout == .vertical ? 400 : 380)
        #elseif os(iOS)
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
                .foregroundColor(colorScheme == .dark ? .gray : Color(uiColor: .darkGray))
                Spacer()
            }
            .padding(.vertical)
            .background(.ultraThinMaterial, in: Rectangle())
        }
        #endif
        .overlay(alignment: .bottom) {
            if mainViewModel.isConnectionStateShown {
                connectionState
                    .frame(height: 100)
                    .allowsHitTesting(false)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: mainViewModel.isConnectionStateShown)
        .animation(.easeInOut, value: mainViewModel.connectionStateTitle)
        .animation(.easeInOut, value: mainViewModel.isConnected)
    }

    var body: some View {
        if #available(macOS 13, iOS 16, *) {
            NavigationSplitView {
                sidebar
                    .toolbar {
                        chatListToolbar
                    }
                    #if os(macOS)
                    .background(SplitViewAccessor(sideCollapsed: $mainViewModel.isChatListVisible))
                    #endif
            } detail: {
                NavigationStack {
                    switch viewRouter.currentView {
                    case .selectChat:
                        chatPlaceholder
                    case .chat:
                        ChatView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            #if os(iOS)
                            .introspectNavigationController { vc in
                                let navBar = vc.navigationBar
                                
                                let newNavBarAppearance = UINavigationBarAppearance()
                                newNavBarAppearance.configureWithDefaultBackground()
                                
                                navBar.scrollEdgeAppearance = newNavBarAppearance
                                navBar.compactAppearance = newNavBarAppearance
                                navBar.standardAppearance = newNavBarAppearance
                                navBar.compactScrollEdgeAppearance = newNavBarAppearance
                            }
                            #endif
                    }
                }
            }
        } else {
            Group {
                NavigationView {
                    sidebar
                        .listStyle(.sidebar)
                        .toolbar {
                            chatListToolbar
                        }
                        #if os(macOS)
                        .background(SplitViewAccessor(sideCollapsed: $mainViewModel.isChatListVisible))
                        #endif
                    
                    switch viewRouter.currentView {
                        case .selectChat:
                            chatPlaceholder
                        case .chat:
                            ChatView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                #if os(iOS)
                                .introspectNavigationController { vc in
                                    let navBar = vc.navigationBar
                                    
                                    let newNavBarAppearance = UINavigationBarAppearance()
                                    newNavBarAppearance.configureWithDefaultBackground()
                                    
                                    navBar.scrollEdgeAppearance = newNavBarAppearance
                                    navBar.compactAppearance = newNavBarAppearance
                                    navBar.standardAppearance = newNavBarAppearance
                                    navBar.compactScrollEdgeAppearance = newNavBarAppearance
                                }
                                #endif
                    }
                }
            }
            #if os(iOS)
            .sidebarSize(folderLayout == .vertical ? 400 : 330)
            .fullScreenCover(isPresented: $areSettingsOpen) {
                SettingsContent()
            }
            #endif
            .sheet(isPresented: $mainViewModel.showingLoginScreen) {
                LoginView()
                    .frame(width: 400, height: 500)
            }
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
