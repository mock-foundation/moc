//
//  L10nText.swift
//  
//
//  Created by Егор Яковенко on 29.10.2022.
//

import SwiftUI
import Backend
import Combine

public struct L10nText: View {
    @State public var key: String
    
    @State private var localized: String?
        
    public init(_ key: String) {
        self.key = key
    }
    
    public var body: some View {
        ZStack {
            if let localized {
                Text(localized)
            }
        }
        .onReceive(TdApi.shared.client.updateSubject) { update in
            if case let .option(option) = update {
                if option.name == "language_pack_id" {
                    Task {
                        self.localized = await L10nManager.shared.getString(by: key)
                    }
                }
            }
        }
        .task {
            self.localized = await L10nManager.shared.getString(by: key)
        }
    }
}
