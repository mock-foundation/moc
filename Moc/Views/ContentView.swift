//
//  ContentView.swift
//  Moc
//
//  Created by Егор Яковенко on 24.12.2021.
//

import SwiftUI
import TDLibKit
import Resolver

struct ContentView: View {
	@State private var selectedFolder: Int = 0
	@State private var selectedChat: Int? = -1
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
						SearchField()
							.padding([.leading, .bottom, .trailing], 10.0)
						GeometryReader { proxy in
                            List(mainViewModel.chatList, selection: $selectedChat) { chat in
								NavigationLink(destination: {
									GeometryReader { proxy in
										ChatView()
											.frame(width: proxy.size.width, height: proxy.size.height)
											.navigationTitle("")
											.toolbar {
												ToolbarItem(placement: .navigation) {
                                                    Image("MockChatLogo")
                                                        .resizable()
                                                        .frame(width: 32, height: 32)
                                                        .clipShape(Circle())
												}
												ToolbarItem(placement: .navigation) {
													VStack(alignment: .leading) {
                                                        Text(chat.name)
															.font(.headline)
														Text("Some users were here lol")
															.font(.subheadline)
													}.onTapGesture(count: 2) {
                                                        Task {
                                                            try! await tdApi.sendMessage(chatId: 736211268, inputMessageContent: .inputMessageText(InputMessageText(clearDraft: true, disableWebPagePreview: true, text: FormattedText(entities: [], text: "Это сообщение было отправлено из Moc!"))), messageThreadId: nil, options: nil, replyMarkup: nil, replyToMessageId: nil)
                                                        }
														selectedChat = 2
													}
												}
												ToolbarItemGroup {
													Button(action: {
														print("search")
													}, label: {
														Image(systemName: "magnifyingglass")
													})
													Button(action: {
														print("sidebar")
													}, label: {
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
								}) {
                                    ChatItemView(chat: chat)
										.frame(height: 56)
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
        .onReceive(NotificationCenter.default.publisher(for: .updateChatLastMessage)) { data in
            NSLog("Received chat position update")
            Task {
                let chatIds = try! await tdApi.getChats(chatList: .chatListMain, limit: 30).chatIds
                var chatList: [Chat] = []
                var parsedChatList: [ChatItem] = []
                for id in chatIds {
                    chatList.append(try! await tdApi.getChat(chatId: id))
                }
                parsedChatList = chatList.map { chat in
                    return ChatItem(id: chat.id, name: chat.title, messagePreview: "Message preview", sender: "Message sender", showSender: false, type: .group, chatIcon: Image("MockChatLogo"), isPinned: false, time: Date(timeIntervalSinceNow: 0), seen: false)
                }
                mainViewModel.update(chats: parsedChatList)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .authorizationStateWaitPhoneNumber)){ data in
			showingLoginScreen = true
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
