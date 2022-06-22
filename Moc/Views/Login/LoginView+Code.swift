//
//  LoginView+Code.swift
//  Moc
//
//  Created by Егор Яковенко on 23.06.2022.
//

import SwiftUI
import TDLibKit

extension LoginView {
    var codeView: some View {
        VStack {
            Text("Enter the code")
                .font(.title)
            TextField("Code", text: $code)
                .onSubmit {
                    Task {
                        do {
                            withAnimation { showLoadingSpinner = true }
                            try await dataSource.checkAuth(code: code)
                            withAnimation { showLoadingSpinner = false }
                        } catch {
                            showErrorAlert = true
                        }
                    }
                }
                .frame(width: 156)
                .textFieldStyle(.roundedBorder)
            if showLoadingSpinner {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
}
