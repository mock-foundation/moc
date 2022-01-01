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
    @InjectedObject private var mainViewModel: MainViewModel

	private var chats: [ChatItem] = [
		ChatItem(id: UUID(), name: "Telegraph lol", messagePreview: "Hey we have something good for you", sender: "No", showSender: false, type: .channel, chatIcon: Image("MockChatLogo"), isPinned: true, time: Date(timeIntervalSinceNow: 349), seen: false),
		ChatItem(id: UUID(), name: "Chatb", messagePreview: "We wrote some shit here", sender: "No", showSender: false, type: .group, chatIcon: Image("MockChatLogo"), isPinned: true, time: Date(timeIntervalSinceNow: 200), seen: true),
		ChatItem(id: UUID(), name: "Kingsong KS-14MDS (KS14M, KS-14D, KS-14S)", messagePreview: "gotway is bad", sender: "taras", showSender: true, type: .superGroup, chatIcon: Image("MockChatLogo"), isPinned: false, time: Date(timeIntervalSinceNow: 155), seen: true),
		ChatItem(id: UUID(), name: "Normal group yee", messagePreview: "hey", sender: "who lol", showSender: false, type: .group, chatIcon: Image("MockChatLogo"), isPinned: false, time: Date(timeIntervalSinceNow: 90), seen: false),
		ChatItem(id: UUID(), name: "Lisa", messagePreview: "yee iloveu", sender: "rustacean", showSender: false, type: .privateChat, chatIcon: Image("MockChatLogo"), isPinned: false, time: Date(timeIntervalSinceNow: 100), seen: true)
	]
	
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
							List(0..<chats.count, selection: $selectedChat) { index in
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
														Text(chats[index].name)
															.font(.headline)
														Text("Some users were here lol")
															.font(.subheadline)
													}.onTapGesture(count: 2) {
														print("hey")
														//													print("selectedChat \(String(describing: selectedChat))")
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
									ChatItemView(chat: chats[index])
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
		.onReceive(NotificationCenter.default.publisher(for: Notification.Name("AuthorizationPhoneNumberRequired"))){ data in
			showingLoginScreen = true
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
