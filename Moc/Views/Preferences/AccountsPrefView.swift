//
//  AccountsPrefView.swift
//  Moc
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI
import SwiftUIUtils
import Preferences
import TDLibKit
import Resolver
import ImageUtils

struct AccountsPrefView: View {
    @State private var photo: Image?
    @State private var userId: Int64 = 0
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var bioText: String = ""
    @State private var phoneNumber: String = ""

    @State private var loading = true
    @State private var showInitErrorAlert = false

    @Injected private var tdApi: TdApi

    private var background: some View {
        ZStack {
            if photo == nil {
                ProfilePlaceholderView(
                    userId: userId,
                    firstName: firstName,
                    lastName: lastName,
                    style: .large
                ).frame(width: 256, height: 256)
            } else {
                photo!
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 256, height: 256)
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
                        Text(username)
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

                }) {
                    Label("Leave", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .tint(.red)
                .controlSize(.large)
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 24)
            Spacer()
        }
    }

    @Environment(\.colorScheme) private var colorScheme

    private var rightColumnContent: some View {
        Preferences.Container(contentWidth: 400) {
            Preferences.Section(title: "Profile photo:") {
                HStack {
                    Image("MockChatPhoto")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    Button(action: { }) {
                        Label("Change", systemImage: "square.and.pencil")
                    }
                }
                Text("Chat photo that will be shown next to your messages.")
                    .preferenceDescription()
            }
            Preferences.Section(title: "First name:") {
                TextField("First name", text: $firstName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
            }
            Preferences.Section(title: "Last name:") {
                TextField("First name", text: $lastName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
            }
            Preferences.Section(title: "Username:") {
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)

            }
            Preferences.Section(title: "Bio:") {
                TextEditor(text: $bioText)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Preferences.Section(title: "Phone number:") {
                HStack {
                    Text(phoneNumber)
                    Button(action: { }) {
                        Label("Change", systemImage: "square.and.pencil")
                    }
                }
                Text("Your account and all your cloud data — messages, media, contacts, etc. will be moved to the new number.")
                    .preferenceDescription()
            }
        }
        // Text length restrictions
        .onReceive(firstName.publisher) { _ in
            if firstName.count > 64 {
                firstName = String(firstName.prefix(64))
                NSSound.beep()
            }
        }
        .onReceive(lastName.publisher) { _ in
            if lastName.count > 64 {
                lastName = String(lastName.prefix(64))
                NSSound.beep()
            }
        }
        .onReceive(username.publisher) { _ in
            if username.count > 32 {
                username = String(username.prefix(32))
                NSSound.beep()
            }
        }
        .onReceive(bioText.publisher) { _ in
            if bioText.count > 70 {
                bioText = String(bioText.prefix(70))
                NSSound.beep()
            }
        }
    }

    private func getAccountData() async {
        let user = try? await tdApi.getMe()
        guard user != nil else {
            showInitErrorAlert = true
            return
        }

        let userFullInfo = try? await tdApi.getUserFullInfo(userId: user!.id)
        guard userFullInfo != nil else {
            showInitErrorAlert = true
            return
        }

        firstName = user!.firstName
        lastName = user!.lastName
        username = "@\(user!.username)"
        bioText = userFullInfo!.bio
        phoneNumber = "+\(user!.phoneNumber)"
        userId = user!.id

        guard let profilePhoto = user!.profilePhoto else {
            loading = false
            return

        }
        guard let profilePhotoPath = URL(string: profilePhoto.big.local.path) else {
            loading = false
            return

        }
        guard let nsImage = NSImage(contentsOf: profilePhotoPath) else {
            loading = false
            return

        }

        photo = Image(nsImage: nsImage)

        loading = false
    }

    var body: some View {
        if loading {
            ProgressView()
                .progressViewStyle(.circular)
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
                rightColumnContent
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct AccountsPrefView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsPrefView()
    }
}
