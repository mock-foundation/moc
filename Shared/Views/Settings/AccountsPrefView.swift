//
//  AccountsPrefView.swift
//  Moc
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI
import AlertToast
import Backend
import Combine
import Utilities
import Logs
import Resolver
import L10n

// swiftlint:disable type_body_length
struct AccountsPrefView: View {
    @StateObject private var viewModel = AccountsPrefViewModel()

    @State private var photos: [Int] = []
    @State private var photoLoading = false
    @State private var miniThumbnail: Image?

    @State private var userId: Int64 = 0
    @State private var username: String = ""
    @State private var bioText: String = ""
    @State private var phoneNumber: String = ""

    @State private var loading = true
    @State private var showInitErrorAlert = false
    @State private var showLogOutSuccessfulToast = false
    @State private var showLogOutFailedToast = false
    
    private func makePhoto(from file: File) -> Image {
        #if os(macOS)
        Image(nsImage: NSImage(contentsOfFile: file.local.path)!)
        #elseif os(iOS)
        Image(uiImage: UIImage(contentsOfFile: file.local.path)!)
        #endif
    }

    private var photoSwitcher: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(photos, id: \.self) { photo in
                    AsyncTdImage(id: photo) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 316, height: 316)
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    } placeholder: {
                        ProgressView()
                            .frame(width: 316, height: 316)
                    }
                }
            }
        }
        .frame(width: 316, height: 316, alignment: .leading)
    }

    private var background: some View {
        ZStack {
            if photos.isEmpty {
                ProfilePlaceholderView(
                    userId: userId,
                    firstName: viewModel.firstName,
                    lastName: viewModel.lastName,
                    style: .large
                ).frame(width: 316, height: 316)
            } else {
                if photoLoading {
                    ZStack {
                        if miniThumbnail != nil {
                            miniThumbnail!
                                .scaledToFill()
                        }
                        ProgressView()
                    }
                } else {
                    ZStack {
                        photoSwitcher
                        VStack {
                            HStack {
//                                ForEach(0..<photos.count) { _ in
//                                    Capsule(style: .continuous)
//                                        .frame(height: 4)
//                                        .background(Color.white)
//                                }
                            }
                            .padding()
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    private var leftColumnContent: some View {
        VStack {
            ZStack {
                background
                VStack {
                    Spacer()
                    HStack {
                        VStack {
                            Text("\(viewModel.firstName) \(viewModel.lastName)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title)
                            Text(phoneNumber)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title3)
                        }
                        Spacer()
                        Text("@\(username)")
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
                    .padding()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            .frame(width: 316, height: 316)
            .padding()
            // swiftlint:disable multiple_closures_with_trailing_closure
            HStack {
                Button(action: {}) {
                    Label(l10n: "Settings.AddAccount", systemImage: "person.badge.plus")
                }
                .controlSize(.large)
                .buttonStyle(.borderless)
                Spacer()
                Button(role: .destructive, action: {
                    Task {
                        do {
                            try await viewModel.logOut()
                            #if os(macOS)
                            NSSound(named: "Glass")?.play()
                            #endif
                            showLogOutSuccessfulToast = true
                        } catch {
                            #if os(macOS)
                            NSSound(named: "Purr")?.play()
                            #endif
                            showLogOutFailedToast = true
                        }
                    }
                }) {
                    // rectangle.portrait.and.arrow.right
                    Label(l10n: "Settings.Logout",
                          systemImage: "rectangle.portrait.and.arrow.right")
                }
                .tint(.red)
                .controlSize(.large)
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 24)
            Spacer()
        }
    }

    private var rightColumnContent: some View {
        Form {
            Section {
                HStack {
                    AsyncTdImage(id: photos[0]) { image in
                        image
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    } placeholder: { ProgressView() }
                    Button { } label: {
                        Label(l10n: "Common.ChoosePhoto",
                              systemImage: "square.and.pencil")
                    }
                }
                TextField("First name", text: $viewModel.firstName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
                    .onSubmit {
                        viewModel.updateNames()
                    }
                TextField("Last name", text: $viewModel.lastName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
                    .onSubmit {
                        viewModel.updateNames()
                    }
            } footer: {
                L10nText("EditProfile.NameAndPhotoOrVideoHelp")
                    .foregroundStyle(.secondary)
            }
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
                .onSubmit {
                    Task {
                        try await viewModel.setUsername(username)
                    }
                }
            Section {
                TextField("Bio", text: $bioText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        Task {
                            try await viewModel.setBio(bioText)
                        }
                    }
                    .frame(width: 350)
            } footer: {
                L10nText("Settings.About.Help")
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text(phoneNumber)
                Button { } label: {
                    Label(l10n: "Common.Edit", systemImage: "square.and.pencil")
                }
            }
        }
        .frame(minWidth: 300)
        // Text length restrictions
        .onChange(of: username) { _ in
            if username.count > 32 {
                username = String(username.prefix(32))
                SystemUtils.playAlertSound()
            }
        }
        .onChange(of: bioText) { _ in
            if bioText.count > 70 {
                bioText = String(bioText.prefix(70))
                SystemUtils.playAlertSound()
            }
        }
    }

    private func getAccountData() async {
        let user = try? await viewModel.getMe()
        guard user != nil else {
            showInitErrorAlert = true
            return
        }

        let userFullInfo = try? await viewModel.getMeFullInfo()
        guard userFullInfo != nil else {
            showInitErrorAlert = true
            return
        }

        viewModel.firstName = user!.firstName
        viewModel.lastName = user!.lastName
        username = user!.username
        bioText = userFullInfo!.bio?.text ?? ""
        phoneNumber = "+\(user!.phoneNumber)"
        userId = user!.id

        guard let photos = (try? await viewModel.getProfilePhotos()) else {
            loading = false
            return
        }
        
        self.photos = photos.compactMap { chatPhoto in
            return chatPhoto.sizes.last?.photo.id
        }

        loading = false
    }

    var body: some View {
        if loading {
            ProgressView()
                .progressViewStyle(.circular)
                .padding()
                .task {
                    await getAccountData()
                }
                .alert("Failed to get account data.", isPresented: $showInitErrorAlert, actions: {
                    Button("Try again") {
                        Task {
                            await getAccountData()
                        }
                    }
                    Button(role: .cancel, action: {}) {
                        Text("Cancel")
                    }
                })
        } else {
            HStack {
                leftColumnContent
                    .frame(width: 340)
                    .padding(.bottom)
                rightColumnContent
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }.toast(isPresenting: $showLogOutSuccessfulToast) {
                AlertToast(displayMode: .alert, type: .complete(.gray), title: "Logged out successfully!")
            }
            .toast(isPresenting: $showLogOutFailedToast) {
                AlertToast(displayMode: .alert, type: .error(.gray), title: "Log out failed :(")
            }
        }
    }
}

struct AccountsPrefView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsPrefView()
    }
}
