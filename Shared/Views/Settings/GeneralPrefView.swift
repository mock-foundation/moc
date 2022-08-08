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

    @Default(.chatShortcuts) private var chatShortcuts
    
    var body: some View {
        Form {
            Section {
                Button("Chat Shortcuts") {
                    isChatShortcutsSheetOpen = true
                }
            } footer: {
                Text("Save chats to app's menubar and easily access them")
            }
            .sheet(isPresented: $isChatShortcutsSheetOpen) {
                VStack {
                    Button("Close") {
                        isChatShortcutsSheetOpen = false
                    }
                    List {
                        ForEach(chatShortcuts, id: \.self) { chatId in
                            Label(String(chatId), systemImage: "text.bubble") // TODO: make this icon represent the chat type
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
                        chatShortcuts.append(.random(in: 0...Int64.max))
                        isNewChatShortcutSheetOpen = true
                    }
                    .sheet(isPresented: $isNewChatShortcutSheetOpen) {
                        Button("Close") {
                            isNewChatShortcutSheetOpen = false
                        }
                        ChatPickerView()
                            .frame(width: 300, height: 500)
                            .padding()
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
