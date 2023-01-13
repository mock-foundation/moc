//
//  LanguagePrefView.swift
//  Moc
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI
import Backend
import L10n
import Combine

struct LanguagePrefView: View {
    private let tdApi = TdApi.shared
    
    @State private var languagePacks: [LanguagePackInfo] = []
    @State private var selectedPackID: String = ""
    
    var body: some View {
        HStack(spacing: 16) {
            VStack {
                L10nText("Settings.AppLanguage")
                    .font(.largeTitle)
                Divider()
                Form {
                    Toggle(isOn: .constant(true)) {
                        L10nText("Localization.ShowTranslate")
                    }
                }
                Spacer()
            }
            .padding()
            .frame(width: 300)
            List(languagePacks, id: \.self) { pack in
                #if os(macOS)
                HStack {
                    VStack(alignment: .leading) {
                        Text(pack.nativeName)
                            .font(.headline)
                        Text(pack.name)
                            .font(.subheadline)
                    }
                    Spacer()
                    if selectedPackID == pack.id {
                        Image(systemName: "checkmark.circle")
                    } else {
                        Button {
                            Task {
                                try await L10nManager.shared.setLanguage(from: pack)
                            }
                        } label: {
                            L10nText("Common.Select")
                        }.padding(2)
                    }
                }
                #elseif os(iOS)
                Button {
                    Task {
                        try await L10nManager.shared.setLanguage(from: pack)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(pack.name)
                            Text(pack.nativeName)
                        }
                        Spacer()
                        if selectedPackID == pack.id {
                            Image(systemName: "checkmark.circle")
                        }
                    }
                }.buttonStyle(.plain)
                #endif
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding()
        }
        #if os(macOS)
        .listStyle(.inset(alternatesRowBackgrounds: true))
        #endif
        .onReceive(tdApi.client.updateSubject) { update in
            if case let .option(value) = update {
                if value.name == "language_pack_id" {
                    if case let .string(value) = value.value {
                        selectedPackID = value.value
                    }
                }
            }
        }
        .onAppear {
            Task {
                languagePacks = try await tdApi.getLocalizationTargetInfo(onlyLocal: false).languagePacks
                let packID = try await tdApi.getOption(name: "language_pack_id")
                
                if case let .string(optionValueString) = packID {
                    selectedPackID = optionValueString.value
                }
            }
        }
    }
}
