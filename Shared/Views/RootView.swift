//
//  RootView.swift
//  Moc
//
//  Created by Егор Яковенко on 24.12.2021.
//

import Backend
import Logs
import Resolver
import SwiftUI
import Utilities
import OrderedCollections
import Storage
import Introspect
import Defaults

// swiftlint:disable type_body_length file_length
struct RootView: View {
    private let logger = Logs.Logger(category: "RootView", label: "UI")

    @State private var selectedFolder: Int = 0
    @State private var openedChat: Chat?
    @State private var selectedTab: Tab = .chat
    @State private var searchText = ""
    @State private var connectionStateColor = Color.clear
    @State private var isConnectionStateShown = true
    @Default(.folderLayout) private var folderLayout
    
    #if os(iOS)
    @State private var areSettingsOpen = false
    #endif

    @StateObject private var viewModel = MainViewModel()
    
    @Environment(\.colorScheme) var colorScheme
    
    private enum Tab {
        case chat
        case contacts
        case calls
    }
    
    private var chatList: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.chatList) { chat in
                    Button {
                        Task {
                            do {
                                SystemUtils.post(notification: .openChatWithInstance, with: chat)
                                _ = try await TdApi.shared.openChat(chatId: chat.id)
                                if let openedChat {
                                    _ = try await TdApi.shared.closeChat(chatId: openedChat.id)
                                }
                            } catch {
                                logger.error("Error in \(error.localizedDescription)")
                            }
                        }
                        openedChat = chat
                    } label: {
                        ChatItem(chat: chat)
                            .frame(height: viewModel.sidebarSize.chatItemHeight)
                            .padding(6)
                            .background(openedChat == chat ? Color.accentColor.opacity(0.8) : nil)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .environment(\.isChatListItemSelected, openedChat == chat)
                    }
                    .buttonStyle(.plain)
                }
            }
            .if(folderLayout == .vertical) {
                $0.padding(.trailing, 12)
            } else: {
                $0.padding(8)
            }
        }
    }
    
    private var chatListToolbarPlacement: ToolbarItemPlacement {
        #if os(macOS)
        if #available(macOS 13, *) {
            return .automatic
        } else {
            return .status
        }
        #elseif os(iOS)
        return .navigationBarLeading
        #endif
    }
    
    private var chatListToolbar: some ToolbarContent {
        return Group {
            #if os(macOS)
            ToolbarItemGroup(placement: chatListToolbarPlacement) {
                if folderLayout == .horizontal {
                    if #unavailable(macOS 13) {
                        Button(action: toggleSidebar) {
                            Label("Toggle chat list", systemImage: "sidebar.left")
                        }
                    }
                    if viewModel.isChatListVisible {
                        Picker(selection: $selectedTab) {
                            Image(systemName: "bubble.left.and.bubble.right").tag(Tab.chat)
                            Image(systemName: "phone.and.waveform").tag(Tab.calls)
                            Image(systemName: "person.2").tag(Tab.contacts)
                        } label: {
                            EmptyView()
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            #endif
            ToolbarItem(placement: chatListToolbarPlacement) {
                if folderLayout == .horizontal {
                    Spacer()
                }
            }
            ToolbarItem(placement: chatListToolbarPlacement) {
                if viewModel.isChatListVisible {
                    Toggle(isOn: $viewModel.isArchiveOpen) {
                        Image(systemName: viewModel.isArchiveOpen ? "archivebox.fill" : "archivebox")
                    }
                }
            }
            ToolbarItem(placement: chatListToolbarPlacement) {
                if folderLayout == .vertical {
                    Spacer()
                }
            }
            ToolbarItem(placement: chatListToolbarPlacement) {
                if viewModel.isChatListVisible {
                    Button {
                        logger.info("Pressed add chat")
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(
            #selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    
    private func makeFolderItem(
        name: String,
        icon: Image,
        unreadCount: Int,
        chatList: Storage.ChatList,
        horizontal: Bool
    ) -> some View {
        Button {
            viewModel.openChatList = chatList
            selectedTab = .chat
        } label: {
            FolderItem(
                name: name,
                icon: icon,
                unreadCount: unreadCount,
                horizontal: horizontal)
            .background(viewModel.openChatList == chatList
                        ? Color("SelectedColor") : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        #if os(iOS)
        .hoverEffect(viewModel.openChatList == chatList ? .lift : .highlight)
        #endif
    }
    
    private func makeTabSwitcherItem(icon: String, tab: Tab) -> some View {
        Button {
            selectedTab = tab
            openedChat = nil
            viewModel.openChatList = nil
        } label: {
            FolderItem(icon: Image(systemName: icon))
            .background(selectedTab == tab ? Color("SelectedColor") : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        #if os(iOS)
        .hoverEffect(viewModel.openChatList == chatList ? .lift : .highlight)
        #endif
    }
    
    @ViewBuilder
    private func makeFolders(horizontal: Bool) -> some View {
        makeFolderItem(
            name: "All Chats",
            icon: Image(systemName: "bubble.left.and.bubble.right"),
            unreadCount: viewModel.mainUnreadCounter,
            chatList: .main,
            horizontal: horizontal)
        ForEach(viewModel.folders) { folder in
            makeFolderItem(
                name: folder.title,
                icon: Image(tdIcon: folder.iconName),
                unreadCount: folder.unreadCounter,
                chatList: .folder(folder.id),
                horizontal: horizontal)
        }
    }
        
    @ViewBuilder
    private var filterBar: some View {
        ScrollView(folderLayout == .vertical ? .vertical : .horizontal, showsIndicators: false) {
            Group {
                if folderLayout == .vertical {
                    VStack {
                        makeFolders(horizontal: false)
                    }
                } else {
                    HStack {
                        makeFolders(horizontal: true)
                    }
                }
            }
            .frame(alignment: .center)
            .if(folderLayout == .vertical) {
                $0.padding(.bottom)
            } else: {
                #if os(macOS)
                $0
                #elseif os(iOS)
                $0.padding(8)
                #endif
            }
        }
        .if(folderLayout == .vertical) { view in
            view
                .frame(width: viewModel.sidebarSize == .small ? 75 : 90)
                .safeAreaInset(edge: .bottom) {
                    tabSwitcher
                        .padding(.bottom, 4)
                }
        } else: {
            $0
            #if os(iOS)
            .background(.bar, in: Rectangle())
            #endif
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
    
    // Vertical tab switcher
    private var tabSwitcher: some View {
        VStack {
            Divider()
                .frame(width: 40)
            makeTabSwitcherItem(icon: "phone.and.waveform", tab: .calls)
            makeTabSwitcherItem(icon: "person.2", tab: .contacts)
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
        #if os(macOS)
        .safeAreaInset(edge: .top) {
            SearchField()
                .controlSize(.large)
                .if(folderLayout == .vertical) {
                    $0.padding(.trailing, 12)
                } else: {
                    $0.padding(.horizontal, 12)
                }
        }
        #endif
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
                if viewModel.connectionState != .ready {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .transition(.opacity)
                }
                Text(viewModel.connectionState.title)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer()
            }
            .padding()
        }
        .background(.linearGradient(
            Gradient(colors: [
                connectionStateColor,
                (colorScheme == .dark ? Color.black.opacity(0) : .white.opacity(0))
            ]),
            startPoint: .bottom,
            endPoint: .top))
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onChange(of: viewModel.connectionState) { value in
            switch value {
                case .ready:
                    connectionStateColor = .accentColor.opacity(0.7)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isConnectionStateShown = false
                    }
                case .updating:
                    connectionStateColor = .green.opacity(0.7)
                    isConnectionStateShown = true
                case .connectingToProxy:
                    connectionStateColor = .yellow.opacity(0.7)
                    isConnectionStateShown = true
                default:
                    connectionStateColor = colorScheme == .dark ? .darkGray.opacity(0.7) : .white
                    isConnectionStateShown = true
            }
        }
        .animation(.easeInOut, value: connectionStateColor)
        .animation(.easeInOut, value: viewModel.connectionState)
    }
    
    private var sidebar: some View {
        HStack {
            if folderLayout == .vertical {
                filterBar
                    .transition(.move(edge: .leading))
                chats
            } else {
                chats
                    .safeAreaInset(edge: .top) {
                        if !viewModel.isArchiveOpen {
                            filterBar
                                .transition(.move(edge: .top))
                                #if os(macOS)
                                .padding(.horizontal)
                                #endif
                        }
                    }
            }
        }
        #if os(macOS)
        .frame(minWidth: folderLayout == .vertical ? 400 : 380)
        .isSidebarCollapsed($viewModel.isChatListVisible)
        #elseif os(iOS)
        .safeAreaInset(edge: .bottom) {
            tabBar
        }
        #endif
        .animation(.fastStartSlowStop(), value: folderLayout)
        .overlay(alignment: .bottom) {
            if isConnectionStateShown {
                connectionState
                    .frame(height: 100)
                    .allowsHitTesting(false)
            }
        }
        .toolbar {
            chatListToolbar
        }
    }
    
    #if os(iOS)
    var tabBar: some View {
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
    
    @ViewBuilder
    var content: some View {
        if openedChat != nil {
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
        } else {
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

    @ViewBuilder
    var body: some View {
        Group {
            if !viewModel.showingLoginScreen {
                Group {
                    if #available(macOS 13, iOS 16, *) {
                        NavigationSplitView {
                            sidebar
                        } detail: {
                            NavigationStack {
                                content
                            }
                        }
                    } else {
                        NavigationView {
                            sidebar
                                .listStyle(.sidebar)
                            content
                        }
                        #if os(iOS)
                        .sidebarSize(folderLayout == .vertical ? 400 : 330)
                        #endif
                    }
                }
                #if os(iOS)
                .fullScreenCover(isPresented: $areSettingsOpen) {
                    SettingsContent()
                }
                #endif
            } else {
                LoginView(onClose: { viewModel.showingLoginScreen = false })
            }
        }
        .transition(.scale)
        .animation(.spring(), value: viewModel.showingLoginScreen)
    }
}

struct ContentView_Previews: PreviewProvider {
    init() {
        Resolver.register { MockChatService() as (any ChatService) }
        Resolver.register { MockMainService() as (any MainService) }
    }
    
    static var previews: some View {
        RootView()
    }
}

private extension SidebarSize {
    var chatItemHeight: CGFloat {
        switch self {
            case .small:
                return 42
            case .medium:
                return 52
            case .large:
                return 60
        }
    }
}
