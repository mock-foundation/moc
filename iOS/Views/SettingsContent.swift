//
//  SwiftUIView.swift
//
//
//  Created by Егор Яковенко on 21.01.2022.
//

import SwiftUI

private enum PreferenceTab: CaseIterable {
    case general
    case notificationsAndSounds
    case privacy
    case dataAndStorage
    case devices
    case appearance
    case language
    case stickers
    case folders
    
    @ViewBuilder
    var label: some View {
        switch self {
            case .general:
                Label("General", systemImage: "gear")
            case .notificationsAndSounds:
                Label("Notifications and Sounds", systemImage: "bell")
            case .privacy:
                Label("Privacy", systemImage: "lock")
            case .dataAndStorage:
                Label("Data and Storage", systemImage: "externaldrive")
            case .devices:
                Label("Devices", systemImage: "laptopcomputer.and.iphone")
            case .appearance:
                Label("Appearance", systemImage: "paintbrush")
            case .language:
                Label("Language", systemImage: "globe")
            case .stickers:
                Label("Stickers", systemImage: "rectangle.3.group.bubble.left")
            case .folders:
                Label("Folders", systemImage: "folder")

        }
    }
}

struct SettingsContent: View {
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
//        if #available(iOS 16, *) {
//            NavigationSplitView {
//                List(PreferenceTab.allCases, id: \.self) { preference in
//                    NavigationLink {
//                        switch preference {
//                            case .general:
//                                GeneralPrefView()
//                            case .notificationsAndSounds:
//                                NotificationsAndSoundsPrefView()
//                            case .privacy:
//                                PrivacyPrefView()
//                            case .dataAndStorage:
//                                DataAndStoragePrefView()
//                            case .devices:
//                                DevicesPrefView()
//                            case .appearance:
//                                AppearancePrefView()
//                            case .language:
//                                LanguagePrefView()
//                            case .stickers:
//                                StickersPrefView()
//                            case .folders:
//                                FoldersPrefView()
//                        }
//                    } label: {
//                        preference.label
//                    }
//                }
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        Button("Close") {
//                            dismiss()
//                        }
//                    }
//                }
//            } detail: {
//
//            }
//        } else {
            NavigationView {
                List(PreferenceTab.allCases, id: \.self) { preference in
                    Section {
                        NavigationLink {
                            switch preference {
                                case .general:
                                    GeneralPrefView()
                                case .notificationsAndSounds:
                                    NotificationsAndSoundsPrefView()
                                case .privacy:
                                    PrivacyPrefView()
                                case .dataAndStorage:
                                    DataAndStoragePrefView()
                                case .devices:
                                    DevicesPrefView()
                                case .appearance:
                                    AppearancePrefView()
                                case .language:
                                    LanguagePrefView()
                                case .stickers:
                                    StickersPrefView()
                                case .folders:
                                    FoldersPrefView()
                            }
                        } label: {
                            preference.label
                        }
                    }
                }
                .listStyle(.sidebar)
                .navigationTitle("Settings")
                .searchable(text: $searchText, placement: .sidebar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
            }.navigationViewStyle(.columns)
//        }
    }
}

struct SettingsContent_Previews: PreviewProvider {
    static var previews: some View {
        SettingsContent()
    }
}
