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
                        .tag(Int(999))
                    Divider()
                    #endif
                    ForEach(phoneNumberCodes, id: \.name) { info in
                        Text("\(info.countryCode) (+\(info.callingCodes[0]))")
                            .tag(Int(info.callingCodes[0])!)
                    }
                }
                .frame(width: 110)
                TextField("Phone number", text: $phoneNumber)
                    .onSubmit {
                        Task {
                            withAnimation { showLoadingSpinner = true }
                            do {
                                if selectedNumberCode == 999 {
                                    try await service.checkAuth(
                                        phoneNumber: "\(selectedNumberCode)\(phoneNumber)"
                                    )
                                } else {
                                    try await service.checkAuth(
                                        phoneNumber: "+\(selectedNumberCode)\(phoneNumber)"
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
