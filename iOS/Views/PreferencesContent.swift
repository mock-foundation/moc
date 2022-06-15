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

struct PreferencesContent: View {
    @State private var searchText = ""
    @State private var selection: PreferenceTab? = nil
    @Environment(\.dismiss) private var dismiss
    
    @ViewBuilder
    private var sidebar: some View {
        NavigationLink { GeneralPrefView() } label: {
            Label("General", systemImage: "gear")
        }
        NavigationLink { NotificationsAndSoundsPrefView() } label: {
            Label("Notifications and Sounds", systemImage: "bell")
        }
        NavigationLink { PrivacyPrefView() } label: {
            Label("Privacy", systemImage: "lock")
        }
        NavigationLink { DataAndStoragePrefView() } label: {
            Label("Data and Storage", systemImage: "externaldrive")
        }
        NavigationLink { DevicesPrefView() } label: {
            Label("Devices", systemImage: "laptopcomputer.and.iphone")
        }
        NavigationLink { AppearancePrefView() } label: {
            Label("Appearance", systemImage: "paintbrush")
        }
        NavigationLink { LanguagePrefView() } label: {
            Label("Language", systemImage: "globe")
        }
        NavigationLink { StickersPrefView() } label: {
            Label("Stickers", systemImage: "rectangle.3.group.bubble.left")
        }
        NavigationLink { FoldersPrefView() } label: {
            Label("Folders", systemImage: "folder")
        }
        NavigationLink { AccountsPrefView() } label: {
            Label("Accounts", systemImage: "person.circle")
        }
    }
    
    var body: some View {
        if #available(iOS 16, *) {
            NavigationSplitView {
                List(PreferenceTab.allCases, id: \.self, selection: $selection) { preference in
                    NavigationLink(value: preference) {
                        preference.label
                    }
                }
            } detail: {
                if let value = selection {
                    switch value {
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
                } else {
                    EmptyView()
                }
            }
        } else {
            NavigationView {
                List {
                    sidebar
                }
                .listStyle(.sidebar)
                .navigationTitle("Settings")
                .searchable(text: $searchText, placement: .sidebar)
                EmptyView()
            }.navigationViewStyle(.columns)
        }
    }
}

struct PreferencesContent_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesContent()
    }
}
