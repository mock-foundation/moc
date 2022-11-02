//
//  SwiftUIView.swift
//
//
//  Created by Егор Яковенко on 21.01.2022.
//

import SwiftUI
import L10n

struct SettingsContent: View {
    var body: some View {
        TabView {
            GeneralPrefView()
                .tabItem {
                    Label(l10n: "Settings.General", systemImage: "gear")
                }
            NotificationsAndSoundsPrefView()
                .tabItem {
                    Label(l10n: "Settings.NotificationsAndSounds", systemImage: "bell")
                }
            PrivacyPrefView()
                .tabItem {
                    Label(l10n: "Settings.PrivacySettings", systemImage: "lock")
                }
            DataAndStoragePrefView()
                .tabItem {
                    Label(l10n: "Settings.ChatSettings", systemImage: "externaldrive")
                }
            DevicesPrefView()
                .tabItem {
                    Label(l10n: "Settings.Devices", systemImage: "laptopcomputer.and.iphone")
                }
            AppearancePrefView()
                .tabItem {
                    Label(l10n: "Settings.Appearance", systemImage: "paintbrush")
                }
            LanguagePrefView()
                .tabItem {
                    Label(l10n: "Settings.AppLanguage", systemImage: "globe")
                }
            StickersPrefView()
                .tabItem {
                    Label(l10n: "ChatSettings.StickersAndReactions", systemImage: "rectangle.3.group.bubble.left")
                }
            FoldersPrefView()
                .tabItem {
                    Label(l10n: "Settings.ChatFolders", systemImage: "folder")
                }
            AccountsPrefView()
                .tabItem {
                    Label(l10n: "Settings.Accounts", systemImage: "person.circle")
                }
        }
        .frame(minWidth: 800, idealWidth: 900, maxWidth: 1100, maxHeight: 450)
    }
}

struct SettingsContent_Previews: PreviewProvider {
    static var previews: some View {
        SettingsContent()
    }
}
