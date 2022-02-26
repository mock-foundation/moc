//
//  ContentView.swift
//  Moc
//
//  Created by Егор Яковенко on 24.12.2021.
//

import Backend
import Logging
import Resolver
import SPSafeSymbols
import SwiftUI
import Utils
import TDLibKit

private enum Tab {
    case chat
    case contacts
    case calls
}

struct ContentView: View {
    private let logger = Logging.Logger(label: "UI", category: "ContentView")

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

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    ScrollView(showsIndicators: false) {
                        Group {
                            switch selectedTab {
                                case .chat:
                                    ForEach(0 ..< 10, content: { _ in
                                        FolderItemView()
                                    })
                                case .contacts:
                                    Image(.person._2)
                                case .calls:
                                    Image(.phone.andWaveform)
                            }
                        }.frame(alignment: .center)
                    }
                    .frame(minWidth: 70)
                    VStack {
                        SearchField()
                            .padding([.leading, .bottom, .trailing], 15.0)
                        Group {
                            switch selectedTab {
                                case .chat:
                                    List(
                                        isArchiveChatListOpen
                                        ? mainViewModel.archiveChatList
                                        : mainViewModel.mainChatList
                                    ) { chat in
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
                                            .swipeActions {
                                                Button(role: .destructive) {
                                                    logger.info("Pressed Delete button")
                                                } label: {
                                                    Label("Delete chat", systemImage: SPSafeSymbol.trash.name)
                                                }
                                            }
                                    }
                                case .contacts:
                                    Text("Contacts")
                                case .calls:
                                    Text("Calls")
                            }
                        }
                        .frame(minWidth: 320, maxHeight: .infinity)
                    }.toolbar {
                        ToolbarItem(placement: .status) {
                            Picker("", selection: $selectedTab) {
                                Image(.bubble.leftAndBubbleRight).tag(Tab.chat)
                                Image(.phone.andWaveform).tag(Tab.calls)
                                Image(.person._2).tag(Tab.contacts)
                            }.pickerStyle(.segmented)
                        }
                        ToolbarItem(placement: .status) {
                            Spacer()
                        }
                        ToolbarItem(placement: .status) {
                            Toggle(isOn: $isArchiveChatListOpen) {
                                Image(isArchiveChatListOpen ? .archivebox.fill : .archivebox)
                            }
                        }
                        ToolbarItem(placement: .status) {
                            // swiftlint:disable multiple_closures_with_trailing_closure
                            Button(action: { logger.info("Pressed add chat") }) {
                                Image(.square.andPencil)
                            }
                        }
                    }
                }
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
            Image(.bubble.leftAndBubbleRight)
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
