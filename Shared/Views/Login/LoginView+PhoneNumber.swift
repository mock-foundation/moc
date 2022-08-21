//
//  LoginView+PhoneNumber.swift
//  Moc
//
//  Created by Егор Яковенко on 23.06.2022.
//

import SwiftUI
import TDLibKit

extension LoginView {
    func generateCallingCodesInfo(from codes: [String]) -> String {
        if codes.count == 1 {
            return "+\(codes.first!)"
        } else {
            return codes
                .map { code in
                    "+\(code)"
                }
                .joined(separator: ", ")
        }
    }
    
    var phoneNumberView: some View {
        VStack {
            Spacer()
            Text("Enter your phone number")
                .font(.title)
            HStack {
                Picker("", selection: $selectedNumberCode) {
                    #if DEBUG
                    Text("TEST (999)")
                        .tag(CountryInfo(
                            callingCodes: ["999"],
                            countryCode: "TS",
                            englishName: "Test",
                            isHidden: false,
                            name: "TEST"))
                    Divider()
                    #endif
                    ForEach(phoneNumberCodes, id: \.countryCode) { info in
                        if !info.isHidden {
//                            if info.callingCodes.count > 1 {
//                                Menu {
//                                    ForEach(info.callingCodes, id: \.self) { code in
//                                        Text("\(info.countryCode) (+\(code))")
//                                            .tag(info)
//                                    }
//                                } label: {
//                                    Text("\(info.countryCode) (\(generateCallingCodesInfo(from: info.callingCodes)))")
//                                        .tag(info)
//                                }
//                            } else {
                                Text("\(info.countryCode) (\(generateCallingCodesInfo(from: info.callingCodes)))")
                                    .tag(info)
//                            }
                        }
                    }
                }
                .frame(width: 110)
                TextField("Phone number", text: $phoneNumber)
                    .onSubmit {
                        Task {
                            withAnimation { showLoadingSpinner = true }
                            do {
                                if Int(selectedNumberCode.callingCodes.first!)! == 999 {
                                    try await service.checkAuth(
                                        phoneNumber: "\(selectedNumberCode.callingCodes.first!)\(phoneNumber)"
                                    )
                                } else {
                                    try await service.checkAuth(
                                        phoneNumber: "+\(selectedNumberCode.callingCodes.first!)\(phoneNumber)"
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
