//
//  ChatView.swift
//  Moc
//
//  Created by Егор Яковенко on 28.12.2021.
//

import Backend
import Introspect
import Resolver
import SwiftUI
import Utilities
import TDLibKit

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
        let tr = min(min(tr, height / 2), width / 2)
        let tl = min(min(tl, height / 2), width / 2)
        let bl = min(min(bl, height / 2), width / 2)
        let br = min(min(br, height / 2), width / 2)

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

struct ChatView: View {
    @InjectedObject private var viewModel: ChatViewModel
    @State private var inputMessage = ""
    @State private var isInspectorShown = true
    @State private var isHideButtonShown = false
    @FocusState private var isInputFieldFocused

    // MARK: - Input field

    private var inputField: some View {
        HStack(spacing: 16) {
            #if os(iOS)
            if isHideButtonShown {
                Button {
                    isInputFieldFocused = false
                } label: {
                    Image(systemName: "chevron.down")
                        .padding(8)
                        .foregroundColor(.black)
                }
                .background(Color.white)
                .clipShape(Circle())
                .transition(.scale.combined(with: .opacity))
            }
            #endif
            Image(systemName: "paperclip")
                .font(.system(size: 16))
            Group {
                if #available(macOS 13, iOS 16, *) {
                    TextField("Write a message...", text: $inputMessage, axis: .vertical)
                        .lineLimit(20)
                } else {
                    TextField("Write a message...", text: $inputMessage)
                }
            }
            .textFieldStyle(.plain)
            .padding(6)
            .onReceive(inputMessage.publisher) { _ in
                viewModel.updateAction(with: .chatActionTyping)
                // TODO: Handle drafts
            }
            .onSubmit {
                viewModel.sendMessage(inputMessage)
                inputMessage = ""
                viewModel.scrollToEnd()
            }
            .focused($isInputFieldFocused)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    self.isInputFieldFocused = true
                }
            }
            Image(systemName: "face.smiling")
                .font(.system(size: 16))
            if inputMessage.isEmpty {
                Image(systemName: "mic")
                    .font(.system(size: 16))
                    .transition(.scale.combined(with: .opacity))
            }
            if !inputMessage.isEmpty {
                Button {
                    viewModel.sendMessage(inputMessage)
                    inputMessage = ""
                    viewModel.scrollToEnd()
                } label: {
                    Image(systemName: "arrow.up")
                        #if os(macOS)
                        .font(.system(size: 16))
                        .padding(6)
                        #elseif os(iOS)
                        .padding(8)
                        #endif
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
                .background(Color.blue)
                .clipShape(Circle())
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: isInputFieldFocused) { value in
            isHideButtonShown = value
        }
        .animation(.spring(dampingFraction: 0.7), value: inputMessage.isEmpty)
        .animation(.spring(dampingFraction: 0.7), value: isHideButtonShown)
    }

    // MARK: - Chat view

    private var chatView: some View {
        ZStack {
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        Spacer()
                        ForEach(viewModel.messages) { message in
                            HStack {
                                if message.isOutgoing { Spacer() }
                                MessageView(message: message)
                                if !message.isOutgoing { Spacer() }
                            }.if(message.isOutgoing) { view in
                                view.padding(.trailing)
                            } else: { view in
                                view.padding(.leading, 6)
                            }
                        }
                        Color.clear
                            .frame(height: 78)
                    }
                    .introspectScrollView { scrollView in
                        viewModel.scrollView = scrollView
                    }
                    .onAppear {
                        viewModel.scrollViewProxy = proxy
                        viewModel.scrollToEnd()
                    }
                }
                Button {
                    viewModel.scrollToEnd()
                } label: {
                    Image(systemName: "arrow.down")
                }
                .buttonStyle(.plain)
                .padding(12)
                .background(.ultraThinMaterial, in: Circle())
                .clipShape(Circle())
                #if (macOS)
                .background(
                    Circle()
                        .strokeBorder(
                            Color.gray,
                            lineWidth: 1
                        )
                )
                #endif
                .vBottom()
                .hTrailing()
                .padding()
                .padding(.bottom, 64)
            }
            inputField
                .padding(8)
                .background(.ultraThinMaterial, in: Capsule())
                .vBottom()
                .padding()
        }
    }

    // MARK: - Additional inspector stuff

    private func makeInspectorButton(action: @escaping () -> Void, imageName: String, text: String) -> some View {
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

    private func userRow(name: String, status _: UserStatus, photo: Image? = nil) -> some View {
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
                if viewModel.chatPhoto != nil {
                    AsyncTdImage(id: viewModel.chatPhoto!.id) { image in
                        image
                            .resizable()
                            .interpolation(.medium)
                            .antialiased(true)
                    }
                    .frame(width: 86, height: 86)
                    .clipShape(Circle())
                } else {
                    ProfilePlaceholderView(
                        userId: viewModel.chatID,
                        firstName: viewModel.chatTitle,
                        lastName: "",
                        style: .medium
                    )
                    .frame(width: 86, height: 86)
                    .clipShape(Circle())
                }
                Text(viewModel.chatTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .frame(minWidth: 0, idealWidth: nil)
                    .multilineTextAlignment(.center)
                Text("\(viewModel.chatMemberCount ?? 0) members")

                // Quick actions
                HStack(spacing: 24) {
                    makeInspectorButton(
                        action: {},
                        imageName: "person.crop.circle.badge.plus",
                        text: "Add"
                    )
                    makeInspectorButton(
                        action: {},
                        imageName: "bell.slash",
                        text: "Mute"
                    )
                    makeInspectorButton(
                        action: {},
                        imageName: "arrow.turn.up.right",
                        text: "Leave"
                    )
                    .tint(.red)
                }
                .padding(.vertical)
                .frame(minWidth: 0, idealWidth: nil)

                // More info
                Section {
                    ScrollView {
                        switch selectedInspectorTab {
                        case .users:
                            ForEach(0 ..< 10) { index in
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
                } header: {
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
                }
            }
            .padding(.top)
        }
    }

    var body: some View {
        ChatSplitView(isRightViewVisible: isInspectorShown) {
            chatView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } rightView: {
            chatInspector
                .frame(idealWidth: 256, maxWidth: .infinity, maxHeight: .infinity)
        }.navigationTitle("")

            // MARK: - Toolbar

            .toolbar {
                ToolbarItemGroup(placement: .navigation) {
                    // Chat photo
                    if viewModel.chatPhoto != nil {
                        AsyncTdImage(id: viewModel.chatPhoto!.id) { image in
                            image
                                .resizable()
                                .interpolation(.medium)
                                .antialiased(true)
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    } else {
                        ProfilePlaceholderView(
                            userId: viewModel.chatID,
                            firstName: viewModel.chatTitle,
                            lastName: "",
                            style: .small
                        )
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    }
                    // Chat title and quick info
                    VStack(alignment: .leading) {
                        Text(viewModel.chatTitle)
                            .font(.headline)
                        Text("Some users were here lol")
                            .font(.subheadline)
                    }
                }
                
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        print("search")
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    Button { isInspectorShown.toggle() } label: {
                        Image(systemName: "sidebar.right")
                    }
                    Button {
                        print("more")
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
    }
}

struct ChatView_Previews: PreviewProvider {
    init() {
        Resolver.register { MockChatService() as ChatService }
    }

    static var previews: some View {
        ChatView()
            .frame(width: 800, height: 600)
    }
}
