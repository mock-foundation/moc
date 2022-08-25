//
//  LoginView+PhoneNumber.swift
//  Moc
//
//  Created by Егор Яковенко on 23.06.2022.
//

import SwiftUI
import TDLibKit

extension LoginView {
    var phoneNumberView: some View {
        VStack {
            Spacer()
            Text("Enter your phone number")
                .font(.title)
            HStack {
                Picker("", selection: $selectedNumberCode) {
                    #if DEBUG
                    Text("TEST (999)")
                        .tag(PhoneNumberInfo(country: "TEST", phoneNumberPrefix: "999"))
                    Divider()
                    #endif
                    ForEach(phoneNumberCodes, id: \.countryCode) { info in
                        if !info.isHidden {
                            ForEach(info.callingCodes, id: \.self) { code in
                                Text("\(info.countryCode) (+\(code))")
                                    .tag(PhoneNumberInfo(country: info.countryCode, phoneNumberPrefix: code))
                            }
                        }
                    }
                }
                .frame(width: 110)
                TextField("Phone number", text: $phoneNumber)
                    .onSubmit {
                        Task {
                            withAnimation { showLoadingSpinner = true }
                            do {
                                if selectedNumberCode.phoneNumberPrefix == "999" {
                                    try await service.checkAuth(
                                        phoneNumber: "\(selectedNumberCode.phoneNumberPrefix)\(phoneNumber)"
                                    )
                                } else {
                                    try await service.checkAuth(
                                        phoneNumber: "+\(selectedNumberCode.phoneNumberPrefix)\(phoneNumber)"
                                    )
                                }
                            } catch {
                                showErrorAlert = true
                                errorAlertMessage = (error as! TDLibKit.Error).message
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
                        _ = try await service.requestQrCodeAuth()
                    } catch {
                        showErrorAlert = true
                        errorAlertMessage = (error as! TDLibKit.Error).message
                    }
                }
            }
            .padding()
            .buttonStyle(.borderless)
        }
    }
}
