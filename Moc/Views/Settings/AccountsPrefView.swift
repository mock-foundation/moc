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
import TDLibKit

// swiftlint:disable type_body_length
struct AccountsPrefView: View {
    @StateObject private var viewModel = AccountsPrefViewModel()

    @State private var photos: [File] = []
    @State private var photoLoading = false
    @State private var photoFileId: Int64 = 0
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
                ForEach(photos, id: \.id) { photo in
                    makePhoto(from: photo)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 256, height: 256)
                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                }
            }
        }
        .frame(width: 256, height: 256, alignment: .leading)
    }

    private var background: some View {
        ZStack {
            if photos.isEmpty {
                ProfilePlaceholderView(
                    userId: userId,
                    firstName: viewModel.firstName,
                    lastName: viewModel.lastName,
                    style: .large
                ).frame(width: 256, height: 256)
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
        .onReceive(viewModel.updateSubject) { update in
            if case let .file(info) = update {
                let file = info.file
                guard file.id == photoFileId else { return }
                
                photoLoading = !file.local.isDownloadingCompleted
                
                if file.local.isDownloadingCompleted {
                    photos[0] = file
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
            .frame(width: 256, height: 256)
            .padding()
            // swiftlint:disable multiple_closures_with_trailing_closure
            HStack {
                Button(action: {}) {
                    Label("Add account", systemImage: "person.badge.plus")
                }
                .controlSize(.large)
                .buttonStyle(.borderless)
                Spacer()
                Button(role: .destructive, action: {
                    Task {
                        do {
                            _ = try await viewModel.service.logOut()
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
                    Label("Log out",
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
                    makePhoto(from: photos[0])
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    Button(action: {}) {
                        Label("Update profile photo",
                              systemImage: "square.and.pencil")
                    }
                }
            } footer: {
                Text("Chat photo that will be shown next to your messages.")
                    .foregroundStyle(.secondary)
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
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
                .onSubmit {
                    Task {
                        try await viewModel.service.set(username: username)
                    }
                }
            Section {
                TextField("Bio", text: $bioText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        Task {
                            try await viewModel.service.set(bio: bioText)
                        }
                    }
                    .frame(width: 350)
            } footer: {
                Text("Any details such as age, occupation or city. Example: 23 y.o designer from San Francisco.")
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text(phoneNumber)
                Button(action: {}) {
                    Label("Change", systemImage: "square.and.pencil")
                }
            }
        }
        .frame(width: 450)
        // Text length restrictions
        .onReceive(username.publisher) { _ in
            if username.count > 32 {
                username = String(username.prefix(32))
                SystemUtils.playAlertSound()
            }
        }
        .onReceive(bioText.publisher) { _ in
            if bioText.count > 70 {
                bioText = String(bioText.prefix(70))
                SystemUtils.playAlertSound()
            }
        }
    }

    private func getAccountData() async {
        let user = try? await viewModel.service.getMe()
        guard user != nil else {
            showInitErrorAlert = true
            return
        }

        let userFullInfo = try? await viewModel.service.getFullInfo()
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

        guard let profilePhoto = user!.profilePhoto else {
            loading = false
            return
        }
        photoFileId = Int64(profilePhoto.big.id)
        #if os(macOS)
        miniThumbnail = Image(nsImage: NSImage(data: profilePhoto.minithumbnail?.data ?? Data())!)
        #elseif os(iOS)
        miniThumbnail = Image(uiImage: UIImage(data: profilePhoto.minithumbnail?.data ?? Data())!)
        #endif

        guard let photos = (try? await viewModel.service.getProfilePhotos()) else {
            loading = false
            return
        }

        for photo in photos {
            guard let file = try? await viewModel.service.downloadFile(
                by: photo.sizes[2].photo.id,
                priority: 32,
                synchronous: true
            ) else {
                viewModel.logger.error("Failed to download photo \(photo.sizes[2].photo.id)")
                loading = false
                return
            }
            self.photos.append(file)
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
                    .frame(width: 300)
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
