//
//  ChatView.swift
//  Moc
//
//  Created by Егор Яковенко on 28.12.2021.
//

import SwiftUI
import TDLibKit
import SwiftUIUtils
import Resolver
import SystemUtils
import Backend

extension Message: Identifiable { }

extension MessageContent {
    public func toString() -> String {
        switch self {
            case .messageText(let data):
                return data.text.text
            case .messageUnsupported:
                return "This message is unsupported, sorry."
            default:
                return "This message is unsupported, sorry."
        }
    }
}

// thx https://stackoverflow.com/a/56763282
// swiftlint:disable identifier_name
private struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.size.width
        let height = rect.size.height

        // Make sure we do not exceed the size of the rectangle
        let tr = min(min(self.tr, height/2), width/2)
        let tl = min(min(self.tl, height/2), width/2)
        let bl = min(min(self.bl, height/2), width/2)
        let br = min(min(self.br, height/2), width/2)

        path.move(to: CGPoint(x: width / 2.0, y: 0))
        path.addLine(to: CGPoint(x: width - tr, y: 0))
        path.addArc(center: CGPoint(x: width - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)

        path.addLine(to: CGPoint(x: width, y: height - br))
        path.addArc(center: CGPoint(x: width - br, y: height - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

        path.addLine(to: CGPoint(x: bl, y: height))
        path.addArc(center: CGPoint(x: bl, y: height - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)

        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()

        return path
    }
}

struct ChatView<T: ChatDataSourcable>: View {
    @Injected var chatDataSource: T

    let chat: Chat
    @State private var inputMessage = ""
    @State private var isInspectorShown = true
    @Environment(\.colorScheme) var colorScheme

    @Injected private var tdApi: TdApi

    // MARK: - Input field
    private var inputField: some View {
        HStack(spacing: 16) {
            Image(systemName: "paperclip")
                .font(.system(size: 16))
            TextField("Write a message...", text: $inputMessage)
                .textFieldStyle(.plain)
                .padding(6)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(
                        cornerRadius: 16)
                            .strokeBorder(
                                Color("InputFieldBorderColor"),
                                lineWidth: 1)
                )
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
                    //                    ForEach(chatViewModel.messages!) { message in
                    //                        MessageBubbleView(sender: "someone", content: message.content.toString())
                    //                            .frame(idealWidth: nil, maxWidth: 300)
                    //                            .hLeading()
                    //                    }
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
    private func inspectorButton(action: @escaping () -> Void, imageName: String, text: String) -> some View {
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

    private func userRow(name: String, status: UserStatus, photo: Image? = nil) -> some View {
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
            LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
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
                    .multilineTextAlignment(.center)
                Text("a ton of members")

                // Quick actions
                HStack(spacing: 24) {
                    inspectorButton(
                        action: {  },
                        imageName: "person.crop.circle.badge.plus",
                        text: "Add"
                    )
                    inspectorButton(
                        action: {  },
                        imageName: "bell.slash",
                        text: "Mute"
                    )
                    inspectorButton(
                        action: {  },
                        imageName: "arrow.turn.up.right",
                        text: "Leave"
                    )
                }
                .padding(.vertical)
                .frame(minWidth: 0, idealWidth: nil)

                // More info
                Section(content: {
                    ScrollView {
                        switch selectedInspectorTab {
                            case .users:
                                ForEach(0..<10) { index in
                                    userRow(
                                        name: "User \(index)",
                                        status: .userStatusRecently,
                                        photo: Image("MockChatPhoto")
                                    )
                                    .padding(.horizontal, 8)
                                    .frame(minWidth: 0, idealWidth: nil)
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
                }, header: {
                    Picker("", selection: $selectedInspectorTab) {
                        Text("Users").tag(InspectorTab.users)
                        Text("Media").tag(InspectorTab.media)
                        Text("Links").tag(InspectorTab.links)
                        Text("Files").tag(InspectorTab.files)
                        Text("Voice").tag(InspectorTab.voice)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .frame(minWidth: 0, idealWidth: nil)
                    .background(.ultraThinMaterial, in: RoundedCorners(tl: 0, tr: 0, bl: 8, br: 8))
                })

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
            .onReceive(SystemUtils.ncPublisher(for: .updateNewMessage)) { notification in
                let message = (notification.object as? UpdateNewMessage)!.message

//                guard viewRouter.openedChat != nil else { return }

                //            if message.chatId == viewRouter.openedChat!.id {
                //                chatViewModel.messages?.append(message)
                //            }
            }
            .task {
                let history = try? await tdApi.getChatHistory(
                    chatId: chat.id,
                    fromMessageId: 0,
                    limit: 50,
                    offset: 0,
                    onlyLocal: false
                )

                guard history != nil else {
                    NSLog("edren baton")
                    return
                }

                let messages = history!.messages

                guard messages != nil else {
                    NSLog("Pizdec")
                    return
                }

                //                chatViewModel.messages = messages!

                //                if self.messages == [] {
                //                    NSLog("Pizdec")
                //                }
            }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView<MockChatDataSource>(chat: Chat(
            actionBar: .none,
            canBeDeletedForAllUsers: true,
            canBeDeletedOnlyForSelf: true,
            canBeReported: true,
            clientData: "",
            defaultDisableNotification: true,
            draftMessage: nil,
            hasProtectedContent: false,
            hasScheduledMessages: false,
            id: 10294934 /* i just banged my head against the keyboard, so this number is completely random */,
            isBlocked: false,
            isMarkedAsUnread: false,
            lastMessage: nil,
            lastReadInboxMessageId: 102044379 /* the same */,
            lastReadOutboxMessageId: 39439379573 /* again */,
            messageSenderId: nil, messageTtl: 0,
            notificationSettings: ChatNotificationSettings(
                disableMentionNotifications: true,
                disablePinnedMessageNotifications: true,
                muteFor: 10,
                showPreview: false,
                sound: "",
                useDefaultDisableMentionNotifications: true,
                useDefaultDisablePinnedMessageNotifications: true,
                useDefaultMuteFor: true,
                useDefaultShowPreview: true,
                useDefaultSound: true
            ),
            pendingJoinRequests: nil,
            permissions: ChatPermissions(
                canAddWebPagePreviews: true,
                canChangeInfo: true,
                canInviteUsers: true,
                canPinMessages: true,
                canSendMediaMessages: true,
                canSendMessages: true,
                canSendOtherMessages: true,
                canSendPolls: true
            ),
            photo: nil,
            positions: [],
            replyMarkupMessageId: 1023948920349 /* my head hurts */,
            themeName: "",
            title: "Curry Club - Ninjas from the reeds",
            type: .chatTypeBasicGroup(
                .init(basicGroupId: 102343920
                      // i really should use a proper random number generator
                      // instead of using my head as a random number generator
                )
            ),
            unreadCount: 0,
            unreadMentionCount: 0,
            videoChat: VideoChat(
                defaultParticipantId: nil,
                groupCallId: 0,
                hasParticipants: false
            )))
            .frame(width: 800, height: 600)
    }
}
