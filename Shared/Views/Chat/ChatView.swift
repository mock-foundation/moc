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
import Defaults

struct ChatView: View {
    @StateObject var viewModel = ChatViewModel()
    @FocusState var isInputFieldFocused
    @Default(.showDeveloperInfo) var showDeveloperInfo
    
    let logger = Logger(category: "ChatView", label: "UI")
    
    var chatView: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    ZStack {
                        VStack {
                            ForEach(viewModel.messages, id: \.self) { message in
                                MessageView(message: message)
                                    .id(message.first!.id)
                                    .background {
                                        Group {
                                            if viewModel.highlightedMessageId == message.first!.id {
                                                Color.blue.opacity(0.3)
                                            } else {
                                                Color.clear
                                            }
                                        }
                                        .padding(-6)
                                        .transition(.opacity)
                                    }
                            }
                        }
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: Int(proxy.frame(in: .named("scroll")).maxY))
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
                .onReceive(SystemUtils.ncPublisher(for: .scrollToMessage)) { notification in
                    let id = notification.object as! Int64
                    viewModel.highlightMessage(at: id)
                    withAnimation(.fastStartSlowStop) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
                .onAppear {
                    viewModel.scrollViewProxy = proxy
                    viewModel.scrollToEnd()
                }
                .animation(.easeInOut, value: viewModel.highlightedMessageId)
            }
            .onDrop(of: [.fileURL], isTargeted: $viewModel.isDroppingMedia) { itemProviders in
                guard !itemProviders.isEmpty else { return false }
                
                for itemProvider in itemProviders {
                    if #available(macOS 13, iOS 16, *) {
                        _ = itemProvider.loadFileRepresentation(for: .fileURL) { (url, _, error) in
                            guard error == nil else { return }
                            guard let url = url else { return }
                            
                            let fullURL = URL(string: try! String(contentsOf: url))!
                            
                            DispatchQueue.main.async {
                                withAnimation(.spring()) {
                                    viewModel.inputMedia.removeAll(where: { $0 == fullURL})
                                    viewModel.inputMedia.append(fullURL)
                                }
                            }
                        }
                    } else {
                        itemProvider.loadFileRepresentation(
                            forTypeIdentifier: UTType.fileURL.identifier
                        ) { url, error in
                            guard error == nil else { return }
                            guard let url = url else { return }
                            
                            addInputMedia(url: url)
                        }
                        logger.debug("All resulting input media: \(viewModel.inputMedia)")
                    }
                }
                
                return true
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                // Additional checks are there to not trigger UI update
                // a heck amount of times when scrolling, which causes
                // huge lags
                if value > 700 {
                    if viewModel.isScrollToBottomButtonShown == false {
                        viewModel.isScrollToBottomButtonShown = true
                    }
                } else {
                    if viewModel.isScrollToBottomButtonShown == true {
                        viewModel.isScrollToBottomButtonShown = false
                    }
                }
            }
            
            ZStack {
                if viewModel.isScrollToBottomButtonShown {
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
                    .background(Circle().strokeBorder(Color.gray, lineWidth: 1))
                    #endif
                    .hTrailing()
                    .vBottom()
                    .padding(.horizontal)
                    .transition(.move(edge: .trailing))
                }
            }
            .animation(.fastStartSlowStop, value: viewModel.isScrollToBottomButtonShown)
        }
        .safeAreaInset(edge: .bottom) {
            inputField
                .padding(8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding([.horizontal, .bottom])
                .padding(.top, 12)
        }
    }
    
    var body: some View {
        ChatSplitView(isRightViewVisible: viewModel.isInspectorShown) {
            chatView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } rightView: {
            chatInspector
                .frame(idealWidth: 256, maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("")
        // MARK: - Toolbar
        .toolbar {
            toolbar
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    init() {
        Resolver.register { MockChatService() as (any ChatService) }
    }

    static var previews: some View {
        ChatView()
            .frame(width: 800, height: 600)
    }
}
