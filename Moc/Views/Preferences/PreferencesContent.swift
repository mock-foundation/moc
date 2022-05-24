//
//  SwiftUIView.swift
//
//
//  Created by Егор Яковенко on 21.01.2022.
//

import SPSafeSymbols
import SwiftUI

public struct PreferencesContent: View {
    public init() {}

    public var body: some View {
        TabView {
            GeneralPrefView()
                .tabItem {
                    Label("General", systemImage: SPSafeSymbol.gear.name)
                }
            NotificationsAndSoundsPrefView()
                .tabItem {
                    Label("Notifications and Sounds", systemImage: SPSafeSymbol.bell.name)
                }
            PrivacyView()
                .tabItem {
                    Label("Privacy", systemImage: SPSafeSymbol.lock.name)
                }
            DataAndStoragePrefView()
                .tabItem {
                    Label("Data and Storage", systemImage: SPSafeSymbol.externaldrive.name)
                }
            DevicesPrefView()
                .tabItem {
                    Label("Devices", systemImage: SPSafeSymbol.laptopcomputer.andIphone.name)
                }
            AppearancePrefView()
                .tabItem {
                    Label("Appearance", systemImage: SPSafeSymbol.paintbrush.name)
                }
            LanguagePrefView()
                .tabItem {
                    Label("Language", systemImage: SPSafeSymbol.globe.name)
                }
            StickersPrefView()
                .tabItem {
                    Label("Stickers", systemImage: SPSafeSymbol.rectangle._3GroupBubbleLeft.name)
                }
            FoldersPrefView()
                .tabItem {
                    Label("Folders", systemImage: SPSafeSymbol.folder.name)
                }
            AccountsPrefView()
                .tabItem {
                    Label("Accounts", systemImage: SPSafeSymbol.person.circle.name)
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
