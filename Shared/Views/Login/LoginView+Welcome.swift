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
            if showLogo {
                Image("WelcomeScreenImage")
                    .resizable()
                    .frame(width: showContent ? 250 : 320, height: showContent ? 250 : 320)
                    .padding(.top)
                    .transition(.scale)
                    .zIndex(1)
            }
            Group {
                if showContent {
                    Text("Welcome to Moc!")
                        .font(.system(size: 36, weight: .bold))
                    Text("Choose your login method")
                    Button {
                        Task {
                            try? await service.requestQrCodeAuth()
                        }
                    } label: {
                        Label("Continue using QR Code", systemImage: "qrcode")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.bottom, 8)
                    .padding(.top, 56)
                    Button {
                        openedScreen = .phoneNumber
                    } label: {
                        Label("Continue using phone number", systemImage: "phone")
                    }
                    .controlSize(.large)
                }
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
        .animation(.spring(dampingFraction: 0.6), value: showLogo)
        .animation(.spring(), value: showContent)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showLogo = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showContent = true
                }
            }
        }
    }
}
