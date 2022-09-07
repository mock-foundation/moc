//
//  ChatInspector.swift
//  Moc
//
//  Created by Егор Яковенко on 02.09.2022.
//

import SwiftUI
import TDLibKit
import Defaults

struct ChatInspector: View {
    let chatId: Int64
    @StateObject private var viewModel: ChatInspectorViewModel
    @Default(.showDeveloperInfo) var showDeveloperInfo
    
    init(id: Int64) {
        self.chatId = id
        self._viewModel = StateObject(wrappedValue: ChatInspectorViewModel(chatId: id))
    }
    
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
    
    private func makeUserRow(name: String, status: UserStatus, photo: Image? = nil) -> some View {
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
    
    private func makePlaceholder(_ style: PlaceholderStyle) -> some View {
        ProfilePlaceholderView(
            userId: chatId,
            firstName: "N", // TODO: Fix this
            lastName: "A",
            style: style
        )
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
                // Header
                if let photo = viewModel.chatPhoto {
                    AsyncTdImage(id: photo.id) { image in
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
                VStack {
                    Text(viewModel.chatTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .frame(minWidth: 0, idealWidth: nil)
                        .multilineTextAlignment(.center)
                    if showDeveloperInfo {
                        Text("ID: \(String(chatId).trimmingCharacters(in: .whitespaces))")
                            .textSelection(.enabled)
                            .foregroundStyle(.secondary)
                    }
                }
                Text("\(viewModel.chatMemberCount ?? 0) members")
                    .fontWeight(.medium)
                
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
                        switch viewModel.selectedInspectorTab {
                            case .users:
                                ForEach(0 ..< 10) { index in
                                    makeUserRow(
                                        name: "User \(index)",
                                        status: .recently,
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
                    Picker("", selection: $viewModel.selectedInspectorTab) {
                        Text("Users").tag(ChatInspectorTab.users)
                        Text("Media").tag(ChatInspectorTab.media)
                        Text("Links").tag(ChatInspectorTab.links)
                        Text("Files").tag(ChatInspectorTab.files)
                        Text("Voice").tag(ChatInspectorTab.voice)
                    }
                    .pickerStyle(.segmented)
                    .controlSize(.large)
                    .padding()
                    .frame(minWidth: 0, idealWidth: nil)
                    .background(.ultraThinMaterial, in: CornerRectangle(tl: 0, tr: 0, bl: 8, br: 8))
                }
            }
            .padding(.top)
        }
        .onChange(of: chatId) { newValue in
            viewModel.chatId = newValue
        }
    }
}
