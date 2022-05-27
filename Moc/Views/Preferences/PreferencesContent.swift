//
//  SwiftUIView.swift
//
//
//  Created by Егор Яковенко on 21.01.2022.
//

import SwiftUI

public struct PreferencesContent: View {
    public init() {}

    public var body: some View {
        TabView {
            GeneralPrefView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            NotificationsAndSoundsPrefView()
                .tabItem {
                    Label("Notifications and Sounds", systemImage: "bell")
                }
            PrivacyPrefView()
                .tabItem {
                    Label("Privacy", systemImage: "lock")
                }
            DataAndStoragePrefView()
                .tabItem {
                    Label("Data and Storage", systemImage: "externaldrive")
                }
            DevicesPrefView()
                .tabItem {
                    Label("Devices", systemImage: "laptopcomputer.and.iphone")
                }
            AppearancePrefView()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
            LanguagePrefView()
                .tabItem {
                    Label("Language", systemImage: "globe")
                }
            StickersPrefView()
                .tabItem {
                    Label("Stickers", systemImage: "rectangle.3.group.bubble.left")
                }
            FoldersPrefView()
                .tabItem {
                    Label("Folders", systemImage: "folder")
                }
            AccountsPrefView()
                .tabItem {
                    Label("Accounts", systemImage: "person.circle")
                }
        }
        .frame(width: 800)
    }
}

struct PreferencesContent_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesContent()
    }
}
