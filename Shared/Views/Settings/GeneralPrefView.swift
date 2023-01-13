//
//  GeneralPrefView.swift
//  Moc
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI
import Defaults
import Utilities
import L10n

extension Int64: Identifiable {
    public var id: Int64 {
        return self
    }
}

struct GeneralPrefView: View {
    @State private var isNewChatShortcutSheetOpen = false
    @State private var chatId: Int64 = 0
    @State private var chatShortcutsSelection = Set<Int64>()

    @Default(.chatShortcuts) private var chatShortcuts
        
    var body: some View {
        TabView {
            Text("To be implemented")
                .tabItem {
                    L10nText("Settings.General.GeneralTab.Name")
                }
            HStack(spacing: 16) {
                VStack {
                    L10nText("Settings.ChatShortcuts.Name")
                        .font(.largeTitle)
                    L10nText("Settings.ChatShortcuts.Subtitle")
                    Divider()
                    Form {
                        Section {
                            Defaults.Toggle(
                                l10n: "Settings.SavedMessagesShortcutToggle.Title",
                                key: .useSavedMessagesShortcut)
                        } footer: {
                            L10nText("Settings.SavedMessagesShortcutToggle.Subtitle")
                                .font(.caption)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    Spacer()
                }
                .frame(width: 300)
                if chatShortcuts.isEmpty {
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "command")
                                .font(.system(size: 76))
                                .foregroundColor(.gray)
                            L10nText("Settings.ChatShortcuts.NoShortcuts")
                                .font(.title)
                                .foregroundStyle(Color.secondary)
                            L10nText("Settings.ChatShortcuts.NoShortcuts.Subtitle")
                                .foregroundStyle(Color.secondary)
                            Button(l10n: "Common.Create") { // TODO: Localize with Button extension
                                isNewChatShortcutSheetOpen = true
                            }
                            .padding()
                            .buttonStyle(.bordered)
                        }
                        .frame(maxWidth: 300)
                        .multilineTextAlignment(.center)
                        Spacer()
                    }
                } else {
                    VStack(alignment: .leading) {
                        List(chatShortcuts, selection: $chatShortcutsSelection) { chatId in
                            HStack {
                                CompactChatItemView(chatId: chatId)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    chatShortcuts.removeAll(where: { $0 == chatId })
                                } label: {
                                    Label(l10n: "Common.Delete", systemImage: "trash")
                                }
                            }
                        }
                        #if os(macOS)
                        .listStyle(.bordered(alternatesRowBackgrounds: true))
                        #endif
                        HStack {
                            Button {
                                isNewChatShortcutSheetOpen = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            Divider()
                                .frame(maxHeight: 10)
                            Button {
                                for shortcut in chatShortcutsSelection {
                                    chatShortcuts.removeAll(where: { $0 == shortcut })
                                }
                            } label: {
                                Image(systemName: "minus")
                            }
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .frame(minWidth: 250, minHeight: 300)
            .padding(8)
            .sheet(isPresented: $isNewChatShortcutSheetOpen) {
                VStack(spacing: 8) {
                    Button {
                        isNewChatShortcutSheetOpen = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                    .hTrailing()
                    Text("""
                        Chat picker is in development, will be done in Stage 3
                        Please insert the chat ID instead, you can find it \
                        in the chat inspector with "Show developer info" \
                        enabled
                        """)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    TextField("Chat ID", value: $chatId, formatter: NumberFormatter())
                        .onSubmit {
                            if chatId != 0 {
                                if !chatShortcuts.contains(chatId) {
                                    chatShortcuts.append(chatId)
                                    isNewChatShortcutSheetOpen = false
                                    self.chatId = 0
                                }
                            }
                        }
                        .textFieldStyle(.roundedBorder)
                }
                .frame(maxWidth: 200, maxHeight: 300)
                .padding()
            }
            .tabItem {
                L10nText("Settings.ChatShortcuts.Name")
            }
            VStack {
                Form {
                    Section {
                        Defaults.Toggle(l10n: "Settings.ShowDeveloperInfo", key: .showDeveloperInfo)
                    } footer: {
                        L10nText("Settings.ShowDeveloperInfo.Explanation")
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
            }
            .tabItem {
                L10nText("Settings.General.Advanced.Name")
            }
        }
        .tabViewStyle(.automatic)
        .padding()
    }
}

struct GeneralPrefView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralPrefView()
    }
}
