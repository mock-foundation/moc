//
//  SwiftUIView.swift
//
//
//  Created by Егор Яковенко on 21.01.2022.
//

import SFSymbols
import SwiftUI

public struct PreferencesContent: View {
    public init() {}

    public var body: some View {
        TabView {
            GeneralPrefView()
                .tabItem {
                    Label("General", systemImage: SFSymbol.gear.name)
                }
            NotificationsAndSoundsPrefView()
                .tabItem {
                    Label("Notifications and Sounds", systemImage: SFSymbol.bell.name)
                }
            PrivacyView()
                .tabItem {
                    Label("Privacy", systemImage: SFSymbol.lock.name)
                }
            DataAndStoragePrefView()
                .tabItem {
                    Label("Data and Storage", systemImage: SFSymbol.externaldrive.name)
                }
            DevicesPrefView()
                .tabItem {
                    Label("Devices", systemImage: SFSymbol.laptopcomputer.andIphone.name)
                }
            AppearancePrefView()
                .tabItem {
                    Label("Appearance", systemImage: SFSymbol.paintbrush.name)
                }
            LanguagePrefView()
                .tabItem {
                    Label("Language", systemImage: SFSymbol.globe.name)
                }
            StickersPrefView()
                .tabItem {
                    Label("Stickers", systemImage: SFSymbol.rectangle._3GroupBubbleLeft.name)
                }
            FoldersPrefView()
                .tabItem {
                    Label("Folders", systemImage: SFSymbol.folder.name)
                }
            AccountsPrefView()
                .tabItem {
                    Label("Accounts", systemImage: SFSymbol.person.circle.name)
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
