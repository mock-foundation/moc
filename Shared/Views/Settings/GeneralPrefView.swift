//
//  GeneralPrefView.swift
//  Moc
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI
import Defaults

struct GeneralPrefView: View {
    @State private var isChatShortcutsSheetOpen = false
    @State private var isNewChatShortcutSheetOpen = false
    @State private var chatId: Int64 = 0

    @Default(.chatShortcuts) private var chatShortcuts
        
    var body: some View {
        Form {
            Section {
                Defaults.Toggle("Show developer info", key: .showDeveloperInfo)
            } footer: {
                Text("""
                    When enabled, Moc will show additional data in the \
                    chat inspector like the chat/user ID.
                    """)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
            }
            Section {
                Button("Chat Shortcuts") {
                    isChatShortcutsSheetOpen = true
                }
            } footer: {
                Text("Save chats to app's menubar and easily access them")
                    .font(.caption)
            }
            .sheet(isPresented: $isChatShortcutsSheetOpen) {
                VStack {
                    Button("Close") {
                        isChatShortcutsSheetOpen = false
                    }
                    List {
                        ForEach(chatShortcuts, id: \.self) { chatId in
                            CompactChatItemView(chatId: chatId)
//                            Label(String(chatId), systemImage: "text.bubble") // TODO: make this icon represent the chat type
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        chatShortcuts.removeAll(where: { $0 == chatId })
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    Button("Add") {
                        isNewChatShortcutSheetOpen = true
                    }
                    .sheet(isPresented: $isNewChatShortcutSheetOpen) {
                        Button("Close") {
                            isNewChatShortcutSheetOpen = false
                        }.padding()
                        Text(
                            """
                            Chat picker is in development, will be done in Stage 3
                            Please insert the chat ID instead, you can find it \
                            in the chat inspector with "Show developer info" \
                            enabled
                            """)
                        TextField("Chat ID", value: $chatId, formatter: NumberFormatter())
                            .onSubmit {
                                chatShortcuts.append(chatId)
                                chatId = 0
                            }
//                        ChatPickerView()
//                            .frame(width: 300, height: 500)
//                            .padding()
                    }
                }
                .frame(minWidth: 250, minHeight: 300)
                .padding(8)
            }
        }
        .padding(8)
    }
}

struct GeneralPrefView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralPrefView()
    }
}
