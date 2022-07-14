//
//  EmojiView.swift
//  Moc
//
//  Created by DariaMikots on 12.07.2022.
//

import SwiftUI
import Resolver
struct EmojiView: View {
    
    @ObservedObject private  var viewModel: EmojiViewModel
    
    init(viewModel: EmojiViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            //Category
            HStack(spacing: 12){
                    ForEach(EmojiViewModel.EmojiCategory.allCases, id: \.id){ item in
                        Text(item.rawValue)
                            .onTapGesture {
                                Task {
                                    await viewModel.getEmojiFromCategory(emojiName:item.stringValue)
                                }
                            }
                    }
            }
            TextField("Search", text: $viewModel.emojiSearch)
                .padding(.horizontal)
            ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 6), spacing: 10) {
                        ForEach(viewModel.emoji , id: \.id) { item in
                            Text(item.emoji)
                                .onTapGesture {
                                    
                                }
                                .id(0)
                        }
                    }
                }
            .frame(maxHeight: 150)
            .onAppear{
                Task {
                    await viewModel.getFavoriteEmoji()
                }
            }
        }
        .padding()
    }
}

