//
//  LoginView.swift
//  Moc
//
//  Created by Егор Яковенко on 25.12.2021.
//

import SwiftUI
import TDLibKit
import Resolver
import SwiftUIUtils

private enum OpenedScreen {
    case phoneNumber
    case qrCode
    case code
    case registration
    case twoFACode
//    case welcome
}

struct LoginView: View {
    func stepView(number: Int, text: String) -> some View {
        HStack {
            ZStack {
                Color.blue
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("\(number)")
                    .foregroundColor(.white)
            }
                .frame(width: 20, height: 20)
            // swiftlint:disable force_try
            Text(try! AttributedString(markdown: text))
            Spacer()
        }
    }

    @State private var phoneNumber: String = ""
    @State private var code = ""
    @State private var twoFactorAuthPassword = ""
    @State private var openedScreen = OpenedScreen.phoneNumber
    @State private var showExitAlert = false

    @Environment(\.presentationMode) private var presentationMode

    @Injected private var tdApi: TdApi

    var body: some View {
        // swiftlint:disable multiple_closures_with_trailing_closure
        ZStack {
            Button(action: {
                showExitAlert = true
            }) {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.escape, modifiers: [])
            .hTrailing()
            .vTop()
            .padding()

            switch openedScreen {
                case .phoneNumber:
                    VStack {
                        Image("WelcomeScreenImage")
                            .resizable()
                            .frame(width: 156, height: 156)
                            .padding(.top, 56)
                        Text("Welcome to Moc!")
                            .font(.title)
                            .padding(.bottom)
                        Text("Enter your phone number")
                            .font(.title3)
                        TextField("Phone number", text: $phoneNumber)
                            .onSubmit {
                                Task {
                                    _ = try await tdApi.setAuthenticationPhoneNumber(
                                        phoneNumber: phoneNumber,
                                        settings: nil
                                    )
                                }
                            }
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 156)
                        Spacer()
                        Button("Use QR Code") {
                            Task {
                                try? await tdApi.requestQrCodeAuthentication(otherUserIds: nil)
                            }
                        }
                        .padding()
                        .buttonStyle(.borderless)
                    }

                case .code:
                    VStack {
                        Text("Enter the code")
                            .font(.title)
                        TextField("Code", text: $code)
                            .onSubmit {
                                Task {
                                    do {
                                        try await tdApi.checkAuthenticationCode(code: code)
                                    } catch {
                                        fatalError("Failed to set authentication code.")
                                    }
                                }
                            }
                            .padding()
                            .textContentType(.password)
                            .textFieldStyle(.roundedBorder)
                    }
                case .qrCode:
                    VStack(spacing: 12) {
                        Text("Login using a QR code")
                            .font(.title)
                            .padding(.top)
                        // QR Code
                        Rectangle()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        VStack {
                            stepView(number: 1, text: "Open Telegram from your phone")
                            stepView(number: 2, text: "Go to **Settings** -> **Devices** -> **Connect device**.")
                            stepView(number: 3, text: "To confirm, point your phone camera to the QR code.")
                        }
                            .frame(width: 200)
                            .padding()
//                        Button("Use phone number") {
//                            Task {
//                                openedScreen = .phoneNumber
//                            }
//                        }
//                        .buttonStyle(.borderless)
                    }
                    .padding()

                case .registration:
                    Text("Register a new Telegram account")
                        .font(.title)
                case .twoFACode:
                    Text("Enter your 2-Factor authentication password")
                    TextField("Password", text: $twoFactorAuthPassword)
                        .onSubmit {
                            Task {
                                try? await tdApi.checkAuthenticationPassword(password: twoFactorAuthPassword)
                            }
                        }
                        .textFieldStyle(.roundedBorder)
                        .padding()
            }

        }
        .alert("You sure you want to exit?", isPresented: $showExitAlert) {
            Button("Yea!") {
                presentationMode.wrappedValue.dismiss()
                NSApp.terminate(self)
            }
            Button("Not really") { }
        }
        .onReceive(NotificationCenter.default.publisher(
            for: .authorizationStateWaitOtherDeviceConfirmation,
            object: nil
        )) { _ in
            openedScreen = .qrCode
        }
        .onReceive(NotificationCenter.default.publisher(for: .authorizationStateWaitRegistration, object: nil)) { _ in
            openedScreen = .registration
        }
        .onReceive(NotificationCenter.default.publisher(for: .authorizationStateWaitPassword, object: nil)) { _ in
            openedScreen = .twoFACode
        }
        .onReceive(NotificationCenter.default.publisher(for: .authorizationStateWaitCode, object: nil)) { _ in
            openedScreen = .code
        }
        .onReceive(NotificationCenter.default.publisher(for: .authorizationStateReady, object: nil)) { _ in
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
