//
//  LoginView.swift
//  Moc
//
//  Created by Егор Яковенко on 25.12.2021.
//

import SwiftUI
import TDLibKit
import Resolver

private enum OpenedScreen {
    case phoneNumber
    case qrCode
    case code
    case registration
    case twoFACode
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
    @Environment(\.presentationMode) private var presentationMode
    @State private var code = ""
    @State private var openedScreen = OpenedScreen.phoneNumber
    @Injected private var tdApi: TdApi

    var body: some View {
        VStack {
            switch openedScreen {
                case .phoneNumber:
                    Text("Enter your phone number")
                        .font(.title3)
                    TextField("Phone number", text: $phoneNumber)
                        .onSubmit {
                            Task {
                                _ = try await tdApi.setAuthenticationPhoneNumber(phoneNumber: phoneNumber, settings: nil)
                            }
                        }
                        .textFieldStyle(.roundedBorder)
                        .padding()

                case .code:
                    Text("Enter the code")
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
                        .textFieldStyle(.roundedBorder)

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
                            stepView(number: 2, text: "Open **Settings** -> **Devices** -> **Connect device**.")
                            stepView(number: 3, text: "To confirm, point your phone camera to the QR code.")
                        }
                            .frame(width: 200)
                            .padding()
                    }.padding()
                    
                case .registration:
                    Text("Registration (WIP)")
                case .twoFACode:
                    Text("Enter your 2-Factor authentication password")
            }

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
