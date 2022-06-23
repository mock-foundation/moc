//
//  LoginView+2FACode.swift
//  Moc
//
//  Created by Егор Яковенко on 23.06.2022.
//

import SwiftUI
import TDLibKit

extension LoginView {
    var twoFACode: some View {
        VStack {
            Text("Enter your Two Factor Authentication (2FA) password")
                .font(.title)
                .multilineTextAlignment(.center)
                
            SecureField("Password", text: $twoFactorAuthPassword)
                .onSubmit {
                    Task {
                        withAnimation { showLoadingSpinner = true }
                        if (try? await service.checkAuth(
                            password: twoFactorAuthPassword
                        )) == nil {
                            showErrorAlert = true
                        }
                        withAnimation { showLoadingSpinner = false }
                    }
                }
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)
                .padding()
            if showLoadingSpinner {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
}
