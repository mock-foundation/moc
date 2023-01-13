//
//  LoginView+QRCode.swift
//  Moc
//
//  Created by Егор Яковенко on 23.06.2022.
//

import SwiftUI
import TDLibKit

extension LoginView {
    var qrCodeView: some View {
        VStack(spacing: 12) {
            Text("Login using a QR code")
                .font(.title)
                .padding(.top)
            // QR Code
            #if os(macOS)
            let image = Image(nsImage: .generateQRCode(from: qrCodeLink))
            #elseif os(iOS)
            let image = Image(uiImage: .generateQRCode(from: qrCodeLink))
            #endif
            image
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 250, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            VStack {
                stepView(number: 1, text: "Open Telegram from your phone")
                stepView(number: 2, text: "Go to **Settings** -> **Devices** -> **Connect device**.")
                stepView(number: 3, text: "To confirm, point your phone camera to the QR code.")
            }
            
//            Button("Use phone number") {
//                Task {
//                    openedScreen = .phoneNumber
//                }
//            }
//            .buttonStyle(.borderless)
//            .frame(width: 200)
//            .padding()
        }
        .padding()
    }
}
