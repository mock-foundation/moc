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
import Utilities

enum OpenedLoginScreen {
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
    let logger = Logs.Logger(category: "Login", label: "UI")
    @Injected var service: LoginService

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

    @State var phoneNumber: String = ""
    @State var code = ""
    @State var twoFactorAuthPassword = ""
    @State var qrCodeLink = ""
    
    @State var phoneNumberCodes: [CountryInfo] = []
    @State var selectedNumberCode: Int = 0

    @State var openedScreen = OpenedLoginScreen.welcome
    
    @State var showErrorAlert = false
    @State var errorAlertMessage = ""

    @State var showExitAlert = false
    @State var showLoadingSpinner = false
    @State var showLogo = false
    @State var showContent = false

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Button {
                showExitAlert = true
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.escape, modifiers: [])
            .hTrailing()
            .vTop()
            .padding()

            Group {
                switch openedScreen {
                    case .welcome:
                        welcome
                    case .phoneNumber:
                        phoneNumberView
                    case .code:
                        codeView
                    case .qrCode:
                        qrCodeView
                    case .registration:
                        registration
                    case .twoFACode:
                        twoFACode
                }
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
                .combined(with: .opacity))
        }
        .animation(.spring(), value: openedScreen)
        .task {
            let countries = try? await service.countries
            guard countries != nil else { return }

            self.phoneNumberCodes = countries!
            let countryCode = (try? await service.countryCode) ?? "EN"

            for country in countries! where country.countryCode == countryCode {
                self.selectedNumberCode = Int(country.callingCodes[0])!
                logger.info("Country code: \(self.selectedNumberCode)")
            }
        }
        .alert(
            "Whoops!",
            isPresented: $showErrorAlert,
            actions: {},
            message: { Text(errorAlertMessage) }
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
        .onReceive(service.updateSubject) { update in
            if case let .authorizationState(info) = update {
                // swiftlint:disable empty_enum_arguments
                switch info.authorizationState {
                    case let .waitOtherDeviceConfirmation(info):
                        self.qrCodeLink = info.link
                        openedScreen = .qrCode
                    case .waitRegistration(_):
                        openedScreen = .registration
                    case .waitPassword(_):
                        openedScreen = .twoFACode
                    case .waitCode(_):
                        openedScreen = .code
                    case .ready:
                        presentationMode.wrappedValue.dismiss()
                    default: break
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
