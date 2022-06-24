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
import UniformTypeIdentifiers
import Logs

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
    @FocusState private var isInputFieldFocused
    
    private let logger = Logger(category: "ChatView", label: "UI")

    // MARK: - Input field

    private var inputField: some View {
        VStack(spacing: 8) {
            if !viewModel.inputMedia.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button {
                            withAnimation(.spring()) {
                                viewModel.inputMedia.removeAll()
                            }
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                        }
                        .padding()
                        
                        ForEach(viewModel.inputMedia, id: \.self) { media in
                            Image(contentsOfFile: media.filePath ?? "")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .contextMenu {
                                    Button(role: .destructive) {
                                        withAnimation(.spring()) {
                                            viewModel.inputMedia.removeAll(where: { $0 == media })
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                        Text("Remove")
                                    }
                                }
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            HStack(spacing: 16) {
                #if os(iOS)
                if viewModel.isHideKeyboardButtonShown {
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
                        TextField(
                            viewModel.isChannel ? "Broadcast..." : "Message...",
                            text: $viewModel.inputMessage,
                            axis: .vertical
                        ).lineLimit(20)
                    } else {
                        TextField(viewModel.isChannel ? "Broadcast..." : "Message...", text: $viewModel.inputMessage)
                    }
                }
                .textFieldStyle(.plain)
                .padding(6)
                .onChange(of: viewModel.inputMessage) { _ in
                    viewModel.updateAction(with: .chatActionTyping)
                    // TODO: Handle drafts
                }
                .onSubmit {
                    viewModel.sendMessage()
                }
                .focused($isInputFieldFocused)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        self.isInputFieldFocused = true
                    }
                }
                Image(systemName: "face.smiling")
                    .font(.system(size: 16))
                if viewModel.inputMessage.isEmpty && viewModel.inputMedia.isEmpty {
                    Image(systemName: "mic")
                        .font(.system(size: 16))
                        .transition(.scale.combined(with: .opacity))
                }
                if !viewModel.inputMessage.isEmpty || !viewModel.inputMedia.isEmpty {
                    Button {
                        viewModel.sendMessage()
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
        }
        .onChange(of: isInputFieldFocused) { value in
            viewModel.isHideKeyboardButtonShown = value
        }
        .animation(.spring(dampingFraction: 0.7), value: viewModel.inputMessage.isEmpty)
        .animation(.spring(dampingFraction: 0.7), value: viewModel.inputMedia.isEmpty)
        .animation(.spring(dampingFraction: 0.7), value: viewModel.inputMedia)
        .animation(.spring(dampingFraction: 0.7), value: viewModel.isHideKeyboardButtonShown)
    }
    
    // MARK: - Chat view

    private var chatView: some View {
        ZStack {
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(viewModel.messages, id: \.self) { message in
                            MessageView(message: message)
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
            .onDrop(of: [.fileURL], isTargeted: $viewModel.isDropping) { itemProviders in
                guard !itemProviders.isEmpty else { return false }
                
                for itemProvider in itemProviders {
                    if #available(macOS 13, iOS 16, *) {
                        _ = itemProvider.loadFileRepresentation(for: .fileURL) { (url, bool, error) in
                            guard error == nil else { return }
                            guard let url = url else { return }
                            
                            Task {
                                await addInputMedia(url)
                            }
                        }
                    } else {
                        itemProvider.loadFileRepresentation(
                            forTypeIdentifier: UTType.fileURL.identifier
                        ) { url, error in
                            guard error == nil else { return }
                            guard let url = url else { return }
                            
                            addInputMedia(url)
                        }
                        logger.debug("All resulting input media: \(viewModel.inputMedia)")
                    }
                }
                
                return true
            }
            inputField
                .padding(8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .vBottom()
                .padding()
        }
    }
    
    func addInputMedia(_ url: URL) {
        let fullURL = URL(string: try! String(contentsOf: url))!
        DispatchQueue.main.async {
            withAnimation(.spring()) {
                viewModel.inputMedia.removeAll(where: { $0 == fullURL })
                viewModel.inputMedia.append(fullURL)
            }
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
    
    private func makePlaceholder(_ style: PlaceholderStyle) -> some View {
        ProfilePlaceholderView(
            userId: viewModel.chatID,
            firstName: viewModel.chatTitle,
            lastName: "",
            style: style
        )
    }

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
                    } placeholder: {
                        makePlaceholder(.medium)
                    }
                    .frame(width: 86, height: 86)
                    .clipShape(Circle())
                } else {
                    makePlaceholder(.medium)
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
        ChatSplitView(isRightViewVisible: viewModel.isInspectorShown) {
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
                        } placeholder: {
                            makePlaceholder(.small)
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    } else {
                        makePlaceholder(.small)
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    }
                    // Chat title and quick info
                    VStack(alignment: .leading) {
                        Text(viewModel.chatTitle)
                            .font(.headline)
                        Text("Chat subtitle")
                            .font(.subheadline)
                    }
                }
                
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        print("search")
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    Button { viewModel.isInspectorShown.toggle() } label: {
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
