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
    @State var selectedNumberCode = PhoneNumberInfo(country: "", phoneNumberPrefix: "")

    @State var openedScreen = OpenedLoginScreen.welcome
    
    @State var showErrorAlert = false
    @State var errorAlertMessage = ""

    @State var showExitAlert = false
    @State var showLoadingSpinner = false
    @State var showLogo = false
    @State var showContent = false
    
    let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }

    var body: some View {
        ZStack {

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
        .frame(maxWidth: 400)
        .onAppear {
            Task {
                guard var countries = try? await service.countries else { return }
                let countryCode = (try? await service.countryCode) ?? "EN"
                
                var callingCode = PhoneNumberInfo(country: "", phoneNumberPrefix: "")
                
                for country in countries where country.countryCode == countryCode {
                    callingCode = PhoneNumberInfo(
                        country: country.countryCode,
                        phoneNumberPrefix: country.callingCodes[0])
                    
                    logger.info("Country code: \(String(describing: self.selectedNumberCode))")
                }
                
                for (index, country) in countries.enumerated() where country.countryCode.lowercased() == "ru" {
                    countries.removeAll(where: { $0.countryCode.lowercased() == "ru" })
                    countries.insert(
                        CountryInfo(
                            callingCodes: country.callingCodes,
                            countryCode: country.countryCode + " [TERR]",
                            englishName: country.englishName,
                            isHidden: country.isHidden,
                            name: country.name),
                        at: index)
                }
                
                countries.sort(by: { $0.countryCode < $1.countryCode })
                countries.removeDuplicates()
                
                self.phoneNumberCodes = countries
                self.selectedNumberCode = callingCode
                
                logger.info("\(try await service.getAuthorizationState())")
                handleAuthorization(state: try await service.getAuthorizationState())
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
                onClose()
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
            if case let .authorizationState(state) = update {
                handleAuthorization(state: state.authorizationState)
            }
        }
    }
    
    private func handleAuthorization(state: AuthorizationState) {
        switch state {
            case let .waitOtherDeviceConfirmation(info):
                self.qrCodeLink = info.link
                openedScreen = .qrCode
            case .waitRegistration:
                openedScreen = .registration
            case .waitPassword:
                openedScreen = .twoFACode
            case .waitPhoneNumber:
                openedScreen = .phoneNumber
            case .waitCode:
                openedScreen = .code
            case .ready:
                onClose()
            default: break
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(onClose: { })
    }
}
