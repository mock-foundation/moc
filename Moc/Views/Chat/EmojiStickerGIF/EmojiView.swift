//
//  EmojiView.swift
//  Moc
//
//  Created by DariaMikots on 12.07.2022.
//

import SwiftUI
import Resolver
import Networking

struct EmojiView: View {
    
    @ObservedObject private  var viewModel: EmojiViewModel
    @Namespace private var topId
    @State private var navigateToNewCategory = false
    
    init(viewModel: EmojiViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            //Category
            HStack(spacing: 12){
                ForEach(EmojiViewModel.EmojiCategory.allCases, id: \.id){ item in
                    Text(item.rawValue)
                        .onTapGesture {
                            Task {
                                await viewModel.getEmojiFromCategory(emojiName:item.stringValue)
                            }
                            navigateToNewCategory.toggle()
                        }
                }
            }
            TextField("Search", text: $viewModel.emojiSearch)
                .padding(.horizontal)
            ScrollViewReader { scrollProxy in
                ScrollView {
                    Color.clear.frame(height: 1)
                        .id(topId)
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 6), spacing: 10) {
                        ForEach(viewModel.emoji , id: \.id) { item in
                            Text(item.emoji)
                                .onTapGesture {
                                    
                                }
                        }
                    }
                }
                .frame(maxHeight: 150)
            .onChange(of: navigateToNewCategory) {  _ in
                    withAnimation {
                        scrollProxy.scrollTo(topId)
                    }
                }
            }
            .onAppear{
                Task {
                    await viewModel.getFavoriteEmoji()
                }
            }
        }
        .padding()
    }
}

