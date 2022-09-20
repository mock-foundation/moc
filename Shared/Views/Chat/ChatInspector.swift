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
    @State private var headerHeight: Int = 0
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

    @ViewBuilder private func makeUserRow(for user: User) -> some View {
        let placeholder = ProfilePlaceholderView(userId: user.id,
                                                 firstName: user.firstName,
                                                 lastName: user.lastName,
                                                 style: .miniature)
        HStack {
            Group {
                if let photo = user.profilePhoto {
                    AsyncTdImage(id: photo.small.id) { image in
                        image
                            .resizable()
                    } placeholder: {
                        placeholder
                    }
                } else {
                    placeholder
                }
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            .padding(8)

            VStack(alignment: .leading) {
                Text("\(user.firstName) \(user.lastName)")
                Text("User status")
            }
            Spacer()
        }
    }

    private func makePlaceholder(_ style: PlaceholderStyle) -> some View {
        ProfilePlaceholderView(
            userId: chatId,
            firstName: viewModel.chatTitle,
            lastName: "",
            style: style
        )
    }

    @ViewBuilder private var headerView: some View {
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
    }

    @ViewBuilder private var quickActionsView: some View {
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
    }

    @ViewBuilder private var sectionsView: some View {
        Section {
            switch viewModel.selectedInspectorTab {
                case .users:
                    ZStack {
                        VStack {
                            ForEach(viewModel.chatMembers, id: \.id) { member in
                                makeUserRow(for: member)
                                    .padding(.horizontal, 8)
                                    .frame(minWidth: 0, idealWidth: nil)
                            }
                        }
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: Int(proxy.frame(in: .named("scrollUsers")).maxY))
                        }
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
        } header: {
            Picker(selection: $viewModel.selectedInspectorTab) {
                Text("Users").tag(ChatInspectorTab.users)
                Text("Media").tag(ChatInspectorTab.media)
                Text("Links").tag(ChatInspectorTab.links)
                Text("Files").tag(ChatInspectorTab.files)
                Text("Voice").tag(ChatInspectorTab.voice)
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
            .controlSize(.large)
            .frame(minWidth: 0, idealWidth: nil)
            .padding(8)
            .background(.ultraThinMaterial, in: Rectangle())
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
                    VStack {
                        headerView
                            .id("header")

                        quickActionsView
                            .id("quickActions")
                    }
                    .background {
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: SizePreferenceKey.self,
                                value: geometry.size
                            )
                        }
                    }
                    .onPreferenceChange(SizePreferenceKey.self) { size in
                        if self.headerHeight != 0 {
                            self.headerHeight = Int(size.height)
                        }
                    }

                    sectionsView
                        .id("sections")
                }
                .padding(.top)
            }
            .coordinateSpace(name: "scrollUsers")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                let newValue = value - headerHeight
                let range = (800...950)
                if range.contains(newValue) {
                    Task {
                        try await viewModel.loadMembers()
                    }
                }
            }
            .onChange(of: chatId) { newValue in
                viewModel.chatId = newValue
                Task {
                    try await viewModel.updateInfo()
                }
                proxy.scrollTo("header", anchor: .top)
            }
            .onChange(of: viewModel.selectedInspectorTab) { _ in
                proxy.scrollTo("sections", anchor: .top)
            }
        }
    }
}
