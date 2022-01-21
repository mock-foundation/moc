//
//  AccountsPrefView.swift
//  Moc
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI
import SwiftUIUtils
import Resolver
import ImageUtils
import SystemUtils
import Combine
import Logging
import AlertToast
import Backend
import TDLibKit

struct AccountsPrefView: View {
    private var logger = Logging.Logger(label: "AccountsPrefView")
    @StateObject private var viewModel = AccountsPrefViewModel()

    @State private var photos: [File] = []
    @State private var photoLoading = false
    @State private var photoFileId: Int64 = 0
    @State private var miniThumbnail: Image?

    @State private var userId: Int64 = 0
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var bioText: String = ""
    @State private var phoneNumber: String = ""

    @State private var loading = true
    @State private var showInitErrorAlert = false
    @State private var showLogOutSuccessfulToast = false
    @State private var showLogOutFailedToast = false

    @State private var index: Int = 0
    @State private var offset: CGFloat = 0
    @State private var isUserSwiping: Bool = false

    private var photoSwitcher: some View {
        ZStack {
            VStack {
                HStack {
                    ForEach(0..<photos.count) {_ in
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .padding(4)
                            .frame(maxWidth: .infinity, maxHeight: 4)
                            .background(Color.white)
                    }
                }
                .padding()
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(photos, id: \.id) { photo in
                        Image(nsImage: NSImage(contentsOf: URL(string: "file://\(photo.local.path)")!)!)
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 256, height: 256)
                    }
                }
            }
            .content
            .animation(.spring(), value: self.index)
            .offset(x: self.isUserSwiping ? self.offset : CGFloat(self.index) * -256)
            .frame(width: 256, height: 256, alignment: .leading)
        }.frame(width: 256, height: 256)
    }

    private var background: some View {
        ZStack {
            if photos.isEmpty {
                ProfilePlaceholderView(
                    userId: userId,
                    firstName: firstName,
                    lastName: lastName,
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
                        VStack {
                            HStack {
                                ForEach(0..<photos.count) {_ in
                                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                                        .padding(2)
                                        .frame(height: 2)
                                        .background(Color.white)
                                }
                            }
                            .padding()
                            Spacer()
                        }
                        photoSwitcher
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateFile, object: nil)) {
            let file = ($0.object as? UpdateFile)!.file
            guard file.id == photoFileId else { return }

            photoLoading = !file.local.isDownloadingCompleted

            if file.local.isDownloadingCompleted {
                photos[0] = file
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
                            Text("\(firstName) \(lastName)")
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
                Button(action: {

                }) {
                    Label("Add account", systemImage: "person.badge.plus")
                }
                .controlSize(.large)
                .buttonStyle(.borderless)
                Spacer()
                Button(role: .destructive, action: {
                    Task {
                        do {
                            _ = try await viewModel.dataSource.logOut()
                            NSSound(named: "Glass")?.play()
                            showLogOutSuccessfulToast = true
                        } catch {
                            NSSound(named: "Purr")?.play()
                            showLogOutFailedToast = true
                        }
                    }
                }) {
                    Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
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
                    Image(nsImage: NSImage(contentsOf: URL(string: "file://\(photos[0].local.path)")!)!)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    Button(action: { }) {
                        Label("Update profile photo", systemImage: "square.and.pencil")
                    }
                }
            } footer: {
                Text("Chat photo that will be shown next to your messages.")
                    .foregroundStyle(.secondary)
            }
            TextField("First name", text: $lastName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
                .onSubmit {
                    Task {
                        try await viewModel.dataSource.set(lastName: lastName)
                    }
                }
            TextField("Last name", text: $lastName)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
                .onSubmit {
                    Task {
                        try await viewModel.dataSource.set(lastName: lastName)
                    }
                }
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
                .onSubmit {
                    Task {
                        try await viewModel.dataSource.set(username: username)
                    }
                }
            Section {
                TextField("Bio", text: $bioText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        Task {
                            try await viewModel.dataSource.set(bio: bioText)
                        }
                    }
                    .frame(width: 350)
            } footer: {
                Text("Any details such as age, occupation or city. Example: 23 y.o designer from San Francisco.")
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text(phoneNumber)
                Button(action: { }) {
                    Label("Change", systemImage: "square.and.pencil")
                }
            }
        }
        .frame(width: 450)
        // Text length restrictions
        .onReceive(firstName.publisher) { _ in
            if firstName.count > 64 {
                firstName = String(firstName.prefix(64))
                SystemUtils.playAlertSound()
            }
        }
        .onReceive(lastName.publisher) { _ in
            if lastName.count > 64 {
                lastName = String(lastName.prefix(64))
                SystemUtils.playAlertSound()
            }
        }
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
        let user = try? await viewModel.dataSource.getMe()
        guard user != nil else {
            showInitErrorAlert = true
            return
        }

        let userFullInfo = try? await viewModel.dataSource.getFullInfo()
        guard userFullInfo != nil else {
            showInitErrorAlert = true
            return
        }

        firstName = user!.firstName
        lastName = user!.lastName
        username = user!.username
        bioText = userFullInfo!.bio
        phoneNumber = "+\(user!.phoneNumber)"
        userId = user!.id

        guard let profilePhoto = user!.profilePhoto else {
            loading = false
            return

        }
        photoFileId = Int64(profilePhoto.big.id)
        miniThumbnail = Image(nsImage: NSImage(data: profilePhoto.minithumbnail?.data ?? Data())!)

        guard let photos = (try? await viewModel.dataSource.getProfilePhotos()) else {
            loading = false
            return
        }

        for photo in photos {
            guard let file = try? await viewModel.dataSource.downloadFile(
                fileId: photo.sizes[2].photo.id,
                priority: 32,
                synchronous: true
            ) else {
                logger.error("Failed to download photo")
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
                    Button(role: .cancel, action: { }) {
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
