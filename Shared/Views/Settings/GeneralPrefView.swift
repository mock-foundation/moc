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
        }
        .padding(8)
        .sheet(isPresented: $isChatShortcutsSheetOpen) {
            VStack {
                List {
                    ForEach(chatShortcuts, id: \.self) { chatId in
                        Button {
                            
                        } label: {
                            Image(systemName: "text.bubble") // TODO: make this icon represent the chat type
                            Text(String(chatId))
                        }
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
                }
            }
            .frame(minWidth: 250, minHeight: 300)
            .padding(8)
        }
    }
}

struct GeneralPrefView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralPrefView()
    }
}
