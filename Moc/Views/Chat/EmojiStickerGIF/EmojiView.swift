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
        VStack{
        //Category
            HStack{
                
            }
            
        }
        TextField("Search", text: $viewModel.emojiSearch)
            LazyVGrid(columns: Array(repeating: GridItem(), count: 6), spacing: 10) {
                ForEach(viewModel.emoji , id: \.id) { item in
                    Text(item.emoji)
                        .onTapGesture {

                        }
                }
            }
        .onAppear{
            viewModel.getEmoji()
        }
    }
        
}

