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
    }
}
