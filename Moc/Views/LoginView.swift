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
import CoreImage.CIFilterBuiltins
import Logging

private enum OpenedScreen {
    case phoneNumber
    case qrCode
    case code
    case registration
    case twoFACode
    case welcome
}

private struct PasscodeField: View {

    var maxDigits: Int = 4
    var label = "Enter One Time Password"

    @State private var pin: String = ""
    @State private var showPin = true
    @State private var isDisabled = false

    var handler: (String, @escaping (Bool) -> Void) -> Void

    public var body: some View {
        VStack(spacing: 12) {
            Text(label).font(.title)
            ZStack {
                pinDots
                backgroundField
            }
            showPinStack
        }

    }

    private var pinDots: some View {
        HStack {
            Spacer()
            ForEach(0..<maxDigits) { index in
                Image(systemName: self.getImageName(at: index))
                Spacer()
            }
        }
    }

    private var backgroundField: some View {
        let boundPin = Binding<String>(get: { self.pin }, set: { newValue in
            self.pin = newValue
            self.submitPin()
        })

        return TextField("", text: boundPin, onCommit: submitPin)
            .textFieldStyle(.plain)
            .accentColor(.clear)
            .foregroundColor(.clear)
            .disabled(isDisabled)
    }

    private var showPinStack: some View {
        HStack {
            Spacer()
        }
        .frame(height: 16)
        .padding([.trailing])
    }

    private func submitPin() {
        guard !pin.isEmpty else {
            showPin = false
            return
        }

        if pin.count == maxDigits {
            isDisabled = true

            handler(pin) { isSuccess in
                if isSuccess {
                    print("pin matched, go to next page, no action to perfrom here")
                } else {
                    pin = ""
                    isDisabled = false
                    print("this has to called after showing toast why is the failure")
                }
            }
        }

        // this code is never reached under normal circumstances. If the user pastes a text with count higher than the
        // max digits, we remove the additional characters and make a recursive call.
        if pin.count > maxDigits {
            pin = String(pin.prefix(maxDigits))
            submitPin()
        }
    }

    private func getImageName(at index: Int) -> String {
        if index >= self.pin.count {
            return "circle"
        }

        if self.showPin {
            return self.pin.digits[index].numberString + ".circle"
        }

        return "circle.fill"
    }
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
        return !self.isEmpty && (self.rangeOfCharacter(from: numberCharacters) != nil)
    }

}

private extension Int {

    var numberString: String {

        guard self < 10 else { return "0" }

        return String(self)
    }
}

struct LoginView: View {
    private let logger = Logging.Logger(label: "LoginView")
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
    @State private var qrCodeLink = ""

    @State private var phoneNumberCodes: [CountryInfo] = []
    @State private var selectedNumberCode: Int = 0

    @State private var openedScreen = OpenedScreen.welcome

    @State private var showExitAlert = false
    @State private var showErrorAlert = false
    @State private var showLoadingSpinner = false

    @Environment(\.presentationMode) private var presentationMode

    @Injected private var tdApi: TdApi

    //    private func codeNumberCell(index: Int) -> some View {
    //        @State var num: String = ""
    //        return TextField("", text: $num)
    //            .textFieldStyle(.plain)
    //            .frame(width: 10, height: 16)
    //            .border(Color.gray, width: 2)
    //            .onReceive(num.publisher) { _ in
    //                if !num.isNumber() {
    //                    code[index] = nil
    //                }
    //                code[index] = Int(num)!
    //            }
    //    }

    func generateQRCode(from string: String) -> NSImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return NSImage(cgImage: cgimg, size: NSSize(width: 32, height: 32))
            }
        }

        return NSImage(systemSymbolName: "xmark.circle", accessibilityDescription: nil) ?? NSImage()
    }

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
                        Button("Continue using phone number") {
                            openedScreen = .phoneNumber
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding(.bottom, 8)
                        Button("Continue using QR code") {
                            Task {
                                try? await tdApi.requestQrCodeAuthentication(otherUserIds: nil)
                            }
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
                                            try await tdApi.setAuthenticationPhoneNumber(
                                                phoneNumber: "+\(selectedNumberCode)\(phoneNumber)",
                                                settings: nil
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
                                    try await tdApi.requestQrCodeAuthentication(otherUserIds: nil)
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
                        //                        PasscodeField(maxDigits: 5, label: "Enter the code") { code, done in
                        //                            Task {
                        //                                do {
                        //                                    try await tdApi.checkAuthenticationCode(code: code)
                        //                                    done(true)
                        //                                }
                        //                            }
                        //                        }
                        TextField("Code", text: $code)
                            .onSubmit {
                                Task {
                                    do {
                                        withAnimation { showLoadingSpinner = true }
                                        try await tdApi.checkAuthenticationCode(code: code)
                                        withAnimation { showLoadingSpinner = false }
                                    } catch {
                                        showErrorAlert = true
                                    }
                                }
                            }
                            .frame(width: 156)
                            .textContentType(.password)
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
                        Image(nsImage: generateQRCode(from: qrCodeLink))
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
                                    if (try? await tdApi.checkAuthenticationPassword(
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
            let countries = try? await tdApi.getCountries().countries
            guard countries != nil else {
                return
            }
            self.phoneNumberCodes = countries!
            let countryCode = (try? await tdApi.getCountryCode().text) ?? "EN"

            for country in countries! where country.countryCode == countryCode {
                self.selectedNumberCode = Int(country.callingCodes[0])!
                logger.info("Country code: \(self.selectedNumberCode)")
            }
        }
        .alert(
            "Error",
            isPresented: $showErrorAlert,
            actions: { },
            message: { Text("You typed in wrong/bad data. Please try again!") }
        )
        .alert("You sure you want to exit?", isPresented: $showExitAlert) {
            Button("Yea!") {
                presentationMode.wrappedValue.dismiss()
                Task {
                    try? await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
                    NSApp.terminate(self)
                }
            }
            Button("Not really") { }
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
