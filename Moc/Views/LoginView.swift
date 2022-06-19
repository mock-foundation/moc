//
//  LoginView.swift
//  Moc
//
//  Created by Егор Яковенко on 25.12.2021.
//

import Backend
import CoreImage.CIFilterBuiltins
import Logs
import Resolver
import SwiftUI
import TDLibKit

private enum OpenedScreen {
    case phoneNumber
    case qrCode
    case code
    case registration
    case twoFACode
    case welcome
}

private extension String {
    var digits: [Int] {
        var result = [Int]()
        for char in self {
            if let number = Int(String(char)) {
                result.append(number)
            }
        }
        return result
    }

    func isNumber() -> Bool {
        let numberCharacters = NSCharacterSet.decimalDigits.inverted
        return !isEmpty && (rangeOfCharacter(from: numberCharacters) != nil)
    }
}

struct LoginView: View {
    private let logger = Logs.Logger(category: "Login", label: "UI")
    @Injected private var dataSource: LoginService

    func stepView(number: Int, text: String) -> some View {
        HStack {
            ZStack {
                Color.blue
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("\(number)")
                    .foregroundColor(.white)
            }
            .frame(width: 20, height: 20)
            Text(try! AttributedString(markdown: text))
            Spacer()
        }
    }

    @State private var phoneNumber: String = ""
    @State private var code = ""
    @State private var twoFactorAuthPassword = ""
    @State private var qrCodeLink = ""

    @State private var phoneNumberCodes: [CountryInfo] = []
    @State private var selectedNumberCode: Int = 0

    @State private var openedScreen = OpenedScreen.welcome

    @State private var showExitAlert = false
    @State private var showErrorAlert = false
    @State private var showLoadingSpinner = false

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            Button  {
                showExitAlert = true
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.escape, modifiers: [])
            .hTrailing()
            .vTop()
            .padding()

            switch openedScreen {
            case .welcome:
                VStack {
                    Image("WelcomeScreenImage")
                        .resizable()
                        .frame(width: 206, height: 206)
                        .padding(.top)
                    Text("Welcome to Moc!")
                        .font(.largeTitle)
                    Text("Choose your login method")
                    Spacer()
                    Button {
                        openedScreen = .phoneNumber
                    } label: {
                        Label("Continue using phone number", systemImage: "phone")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.bottom, 8)
                    Button {
                        Task {
                            try? await dataSource.requestQrCodeAuth()
                        }
                    } label: {
                        Label("Continue using QR Code", systemImage: "qrcode")
                    }
                    .controlSize(.large)
                    Spacer()
                }
            case .phoneNumber:
                VStack {
                    Spacer()
                    Text("Enter your phone number")
                        .font(.title)
                    HStack {
                        Picker("", selection: $selectedNumberCode) {
                            ForEach(phoneNumberCodes, id: \.name) { info in
                                Text("\(info.countryCode) (+\(info.callingCodes[0]))")
                                    .tag(Int(info.callingCodes[0])!)
                            }
                        }
                        .frame(width: 100)
                        TextField("Phone number", text: $phoneNumber)
                            .onSubmit {
                                Task {
                                    withAnimation { showLoadingSpinner = true }
                                    do {
                                        try await dataSource.checkAuth(
                                            phoneNumber: "+\(selectedNumberCode)\(phoneNumber)"
                                        )
                                    } catch {
                                        showErrorAlert = true
                                    }
                                    withAnimation { showLoadingSpinner = false }
                                }
                            }
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 156)
                    }
                    if showLoadingSpinner {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding()
                    }
                    Spacer()
                    Button("Use QR Code") {
                        Task {
                            do {
                                _ = try await dataSource.requestQrCodeAuth()
                            } catch {
                                showErrorAlert = true
                            }
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
                                    withAnimation { showLoadingSpinner = true }
                                    try await dataSource.checkAuth(code: code)
                                    withAnimation { showLoadingSpinner = false }
                                } catch {
                                    showErrorAlert = true
                                }
                            }
                        }
                        .frame(width: 156)
                        .textFieldStyle(.roundedBorder)
                    if showLoadingSpinner {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
            case .qrCode:
                VStack(spacing: 12) {
                    Text("Login using a QR code")
                        .font(.title)
                        .padding(.top)
                    // QR Code
                    #if os(macOS)
                    let image = Image(nsImage: .generateQRCode(from: qrCodeLink))
                    #elseif os(iOS)
                    let image = Image(uiImage: .generateQRCode(from: qrCodeLink))
                    #endif
                    image
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    VStack {
                        stepView(number: 1, text: "Open Telegram from your phone")
                        stepView(number: 2, text: "Go to **Settings** -> **Devices** -> **Connect device**.")
                        stepView(number: 3, text: "To confirm, point your phone camera to the QR code.")
                    }

//                        Button("Use phone number") {
//                            Task {
//                                openedScreen = .phoneNumber
//                            }
//                        }
//                        .buttonStyle(.borderless)
                    .frame(width: 200)
                    .padding()
                }
                .padding()

            case .registration:
                Text("Register a new Telegram account")
                    .font(.title)
            case .twoFACode:
                VStack {
                    Text("Enter your Two Factor Authentication (2FA) password")
                        .font(.title)
                        .multilineTextAlignment(.center)
                    SecureField("Password", text: $twoFactorAuthPassword)
                        .onSubmit {
                            Task {
                                withAnimation { showLoadingSpinner = true }
                                if (try? await dataSource.checkAuth(
                                    password: twoFactorAuthPassword
                                )) == nil {
                                    showErrorAlert = true
                                }
                                withAnimation { showLoadingSpinner = false }
                            }
                        }
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    if showLoadingSpinner {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
            }
        }
        .task {
            let countries = try? await dataSource.countries
            guard countries != nil else { return }

            self.phoneNumberCodes = countries!
            let countryCode = (try? await dataSource.countryCode) ?? "EN"

            for country in countries! where country.countryCode == countryCode {
                self.selectedNumberCode = Int(country.callingCodes[0])!
                logger.info("Country code: \(self.selectedNumberCode)")
            }
        }
        .alert(
            "Error",
            isPresented: $showErrorAlert,
            actions: {},
            message: { Text("You typed in wrong/bad data. Please try again!") }
        )
        .alert("You sure you want to exit?", isPresented: $showExitAlert) {
            Button("Yea!") {
                presentationMode.wrappedValue.dismiss()
                Task {
                    try? await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
                    #if os(macOS)
                    NSApp.terminate(self)
                    #elseif os(iOS)
                    exit(0)
                    #endif
                }
            }
            Button("Not really") {}
        }
        .onReceive(NotificationCenter.default.publisher(
            for: .authorizationStateWaitOtherDeviceConfirmation,
            object: nil
        )) { notification in
            self.qrCodeLink = (notification.object as? AuthorizationStateWaitOtherDeviceConfirmation)!.link
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
