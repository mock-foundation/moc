//
//  AccountsPrefView.swift
//  Moc
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI
import SwiftUIUtils
import Preferences

struct AccountsPrefView: View {
    @State private var firstName: String = "GGorAA"
    @State private var lastName: String = ""
    @State private var username: String = "@ggoraa"
    @State private var bioText: String = "Kotlin/Swift developer from Kyiv. @https200 github.com/ggoraa"
    @State private var phoneNumber: String = "+3809876567"

    private var leftColumnContent: some View {
        VStack {
            ZStack {
                Image("MockChatPhoto")
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 256, height: 256)
                VStack {
                    Spacer()
                    HStack {
                        VStack {
                            Text("Username")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title)
                            Text("Phone number")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title3)
                        }
                        Spacer()
                        Text("@nickname")
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

    private var rightColumnContent: some View {
        Preferences.Container(contentWidth: 300) {
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
                TextField("First name", text: .constant("GGorAA"))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
            }
            Preferences.Section(title: "Last name:") {
                TextField("First name", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
            }
            Preferences.Section(title: "Username:") {
                TextField("Username", text: .constant("@ggoraa"))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)

            }
            Preferences.Section(title: "Bio:") {
                TextEditor(text: $bioText)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Preferences.Section(title: "Phone number:") {
                HStack {
                    Text("+3809876567")
                    Button(action: { }) {
                        Label("Change", systemImage: "square.and.pencil")
                    }
                }
                Text("Your account and all your cloud data — messages, media, contacts, etc. will be moved to the new number.")
                    .preferenceDescription()
            }
        }
        .onReceive(bioText.publisher) { _ in
            if bioText.count > 70 {
                bioText = String(bioText.prefix(70))
                NSSound.beep()
            }
        }
    }

    var body: some View {
        HStack {
            leftColumnContent
                .frame(width: 300)
            rightColumnContent
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct AccountsPrefView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsPrefView()
    }
}
