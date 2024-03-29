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
    
    enum HeaderStyle {
        case minimal
        case large
    }
    
    @ViewBuilder
    private var headerImage: some View {
        if let photo = viewModel.chatPhoto {
            AsyncTdImage(id: photo.id) { image in
                image
                    .resizable()
                    .interpolation(.medium)
                    .antialiased(true)
            } placeholder: {
                makePlaceholder(.medium)
            }
        } else {
            makePlaceholder(.medium)
        }
    }

    private func makeHeaderView(style: HeaderStyle) -> some View {
        VStack {
            switch style {
                case .minimal:
                    headerImage
                        .frame(width: 86, height: 86)
                        .clipShape(Circle())
                case .large:
                    headerImage
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            VStack(spacing: 0) {
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
                Text("\(viewModel.chatMemberCount ?? 0) members")
                    .fontWeight(.medium)
            }
        }
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
        .padding()
        .frame(minWidth: 0, idealWidth: nil)
    }
    
    var infoTabs: some View {
        ScrollView {
            ZStack {
                switch viewModel.selectedInspectorTab {
                    case .users:
                        VStack {
                            ForEach(viewModel.chatMembers, id: \.id) { member in
                                makeUserRow(for: member)
                                    .padding(.horizontal, 8)
                                    .frame(minWidth: 0, idealWidth: nil)
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
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: InspectorScrollOffsetPreferenceKey.self,
                        value: Int(proxy.frame(in: .named("scrollUsers")).maxY))
                }
            }
        }
        .coordinateSpace(name: "scrollUsers")
        .onPreferenceChange(InspectorScrollOffsetPreferenceKey.self) { value in
            let range = (0...550)
            if range.contains(value) {
                Task {
                    try await viewModel.loadMembers()
                }
            }
        }
        .safeAreaInset(edge: .top) {
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
        .onChange(of: chatId) { newValue in
            viewModel.chatId = newValue
            Task {
                try await viewModel.updateInfo()
            }
        }
    }

    var body: some View {
        GeometryReader { proxy in
            if proxy.size.width >= 600 {
                HStack {
                    VStack {
                        makeHeaderView(style: .large)
                            .padding(.top, 12)
                        quickActionsView
                        Spacer()
                    }
                    .padding(.vertical)
                    infoTabs
                }
            } else {
                VStack {
                    makeHeaderView(style: .minimal)
                        .padding(.top, 8)
                    quickActionsView
                    infoTabs
                }

            }
        }
    }
}
