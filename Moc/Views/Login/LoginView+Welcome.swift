//
//  LoginView+Welcome.swift
//  Moc
//
//  Created by Егор Яковенко on 23.06.2022.
//

import SwiftUI
import TDLibKit

extension LoginView {
    var welcome: some View {
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
                Task {
                    try? await dataSource.requestQrCodeAuth()
                }
            } label: {
                Label("Continue using QR Code", systemImage: "qrcode")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.bottom, 8)
            Button {
                openedScreen = .phoneNumber
            } label: {
                Label("Continue using phone number", systemImage: "phone")
            }
            .controlSize(.large)
            Spacer()
        }
    }
}
