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
    @State private var viewIndex = 0
    
    init() {
        _emojiViewModel = StateObject(wrappedValue: EmojiViewModel(emojiService: EmojiService()))
    }
    
    var body: some View {
        ZStack {
            checkPicker
                .safeAreaInset(edge: .bottom) {
                    Picker("", selection: $viewIndex) {
                        Image(systemName: "face.smiling")
                        Image(systemName: "face.smiling")
                        Image(systemName: "face.smiling")
                    }
                    .frame(width: 100)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .pickerStyle(.segmented)
                }
        }
    }
    @ViewBuilder private var checkPicker: some View {
        ZStack {
            switch viewIndex {
            case 0:
                EmojiView(viewModel: emojiViewModel)
            case 1:
                EmptyView()
            default:
                EmojiView(viewModel: emojiViewModel)
            }
        }
    }
}
