//
//  EmojiStickerGIFView.swift
//  Moc
//
//  Created by DariaMikots on 12.07.2022.
//

import SwiftUI
import Networking

struct EmojiStickerGIFView: View {
    
    @StateObject private var emojiViewModel: EmojiViewModel

    init() {
        _emojiViewModel = StateObject(wrappedValue: EmojiViewModel(emojiService: EmojiService()))
    }

    
    var body: some View {
        TabView {
            EmojiView(viewModel: emojiViewModel)
                .tabItem {
                    Image(systemName: "face.smiling")
                }
        }
    }
}

