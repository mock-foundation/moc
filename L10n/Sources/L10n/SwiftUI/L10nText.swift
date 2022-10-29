//
//  L10nText.swift
//  
//
//  Created by Егор Яковенко on 29.10.2022.
//

import SwiftUI

public struct L10nText: View {
    @State public var key: String
    
    @State private var localized: String?
    
    init(_ key: String) {
        self.key = key
    }
    
    public var body: some View {
        ZStack {
            if let localized {
                Text(localized)
            } else {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(.gray)
                    .frame(width: 42, height: 12)
            }
        }
        .task {
            self.localized = await L10nManager.shared.getString(by: key)
        }
    }
}
