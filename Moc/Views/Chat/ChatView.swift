//
//  ChatView.swift
//  Moc
//
//  Created by Егор Яковенко on 28.12.2021.
//

import SwiftUI
import TDLibKit

struct ChatView: View {
    let chat: Chat
    @State private var inputMessage = ""
    @State private var isInspectorShown = true
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Input field
    private var inputField: some View {
        HStack(spacing: 16) {
            Image(systemName: "paperclip")
                .font(.system(size: 16))
            TextField("Write a message...", text: $inputMessage)
                .textFieldStyle(.plain)
                .padding(6)
                .padding(.horizontal, 8)
                .background(RoundedRectangle(cornerRadius: 16).stroke(Color("InputFieldBorderColor"), lineWidth: 1))
            Image(systemName: "face.smiling")
                .font(.system(size: 16))
            Image(systemName: "mic")
                .font(.system(size: 16))
        }
    }

    // MARK: - Chat view
    private var chatView: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(0..<50) { _ in
                        HStack {
                            MessageBubbleView()
                                .frame(width: 300)
                            Spacer()
                        }
                    }
                }
                .onAppear {
                    proxy.scrollTo(50 - 1)
                }
            }
            inputField
                .padding()
        }
    }

    // MARK: - Additional inspector stuff
    private func InspectorButton(action: @escaping () -> Void, imageName: String, text: String) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: imageName)
                    .font(.system(size: 24))
                    .padding(4)
                Text(text)
            }
        }
        .frame(width: 48, height: 48)
        .buttonStyle(.borderless)
    }

    private func UserRow(name: String, status: UserStatus, photo: Image? = nil) -> some View {
        HStack {
            if photo != nil {
                photo!
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .padding(8)
            }
            VStack(alignment: .leading) {
                Text(name)
                Text("User status")
            }
            Spacer()
        }
    }

    private enum InspectorTab {
        case users
        case media
        case links
        case files
        case voice
    }

    @State private var selectedInspectorTab: InspectorTab = .users

    // MARK: - Chat inspector
    private var chatInspector: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                Image("MockChatPhoto")
                    .resizable()
                    .frame(minWidth: 0, maxWidth: 86, minHeight: 0, maxHeight: 86)
                    .clipShape(Circle())
                Text(chat.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .frame(minWidth: 0, idealWidth: nil)
                Text("a ton of members")

                // Quick actions
                HStack(spacing: 24) {
                    InspectorButton(
                        action: {  },
                        imageName: "person.crop.circle.badge.plus",
                        text: "Add"
                    )
                    Divider()
                    InspectorButton(
                        action: {  },
                        imageName: "bell.slash",
                        text: "Mute"
                    )
                    Divider()
                    InspectorButton(
                        action: {  },
                        imageName: "arrow.turn.up.right",
                        text: "Leave"
                    )
                }
                .padding(.vertical)
                .frame(minWidth: 0, idealWidth: nil)

                // More info
                Picker("", selection: $selectedInspectorTab) {
                    Text("Users").tag(InspectorTab.users)
                    Text("Media").tag(InspectorTab.media)
                    Text("Links").tag(InspectorTab.links)
                    Text("Files").tag(InspectorTab.files)
                    Text("Voice").tag(InspectorTab.voice)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .frame(minWidth: 0, idealWidth: nil)
                ScrollView {
                    switch selectedInspectorTab {
                        case .users:
                            ForEach(0..<10) { index in
                                UserRow(name: "User \(index)", status: .userStatusRecently, photo: Image("MockChatPhoto"))
                                    .padding(.horizontal, 8)
                            }
                        case .media:
                            Text("Media")
                        case .links:
                            Text("Links")
                        case .files:
                            Text("Files")
                        case .voice:
                            Text("Voice")
                    }
                }
            }
            .padding(.top)
        }
    }

    var body: some View {
        ChatSplitView(leftView: {
            chatView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }, rightView: {
            chatInspector
                .frame(idealWidth: 256, maxWidth: .infinity, maxHeight: .infinity)
        }, isRightViewVisible: isInspectorShown)
            .navigationTitle("")
        // MARK: - Toolbar
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Image("MockChatPhoto")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                }
                ToolbarItem(placement: .navigation) {
                    VStack(alignment: .leading) {
                        Text(chat.title)
                            .font(.headline)
                        Text("Some users were here lol")
                            .font(.subheadline)
                    }
                }
                ToolbarItemGroup {
                    Button(action: {
                        print("search")
                    }, label: {
                        Image(systemName: "magnifyingglass")
                    })
                    Button(action: { isInspectorShown.toggle() }, label: {
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
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(chat: Chat(actionBar: .none, canBeDeletedForAllUsers: true, canBeDeletedOnlyForSelf: true, canBeReported: true, clientData: "", defaultDisableNotification: true, draftMessage: nil, hasProtectedContent: false, hasScheduledMessages: false, id: 10294934 /* i just banged my head against the keyboard, so this number is completely random */, isBlocked: false, isMarkedAsUnread: false, lastMessage: nil, lastReadInboxMessageId: 102044379 /* the same */, lastReadOutboxMessageId: 39439379573 /* again */, messageSenderId: nil, messageTtl: 0, notificationSettings: ChatNotificationSettings(disableMentionNotifications: true, disablePinnedMessageNotifications: true, muteFor: 10, showPreview: false, sound: "", useDefaultDisableMentionNotifications: true, useDefaultDisablePinnedMessageNotifications: true, useDefaultMuteFor: true, useDefaultShowPreview: true, useDefaultSound: true), pendingJoinRequests: nil, permissions: ChatPermissions(canAddWebPagePreviews: true, canChangeInfo: true, canInviteUsers: true, canPinMessages: true, canSendMediaMessages: true, canSendMessages: true, canSendOtherMessages: true, canSendPolls: true), photo: nil, positions: [], replyMarkupMessageId: 1023948920349 /* my head hurts */, themeName: "", title: "Curry Club - Ninjas from the reeds", type: .chatTypeBasicGroup(.init(basicGroupId: 102343920 /* i really should use a proper random number generator instead of using my head as a random number generator */)), unreadCount: 0, unreadMentionCount: 0, videoChat: VideoChat(defaultParticipantId: nil, groupCallId: 0, hasParticipants: false)))
            .frame(width: 800, height: 600)
    }
}
