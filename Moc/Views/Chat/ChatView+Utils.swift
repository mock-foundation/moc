//
//  ChatView+Methods.swift
//  Moc
//
//  Created by Егор Яковенко on 08.07.2022.
//

import SwiftUI

extension ChatView {
    func addInputMedia(url: URL) {
        let fullURL = URL(string: try! String(contentsOf: url))!
        DispatchQueue.main.async {
            withAnimation(.spring()) {
                viewModel.inputMedia.removeAll(where: { $0 == fullURL })
                viewModel.inputMedia.append(fullURL)
            }
        }
    }
    
    func makePlaceholder(_ style: PlaceholderStyle) -> some View {
        ProfilePlaceholderView(
            userId: viewModel.chatID,
            firstName: viewModel.chatTitle,
            lastName: "",
            style: style
        )
    }
}
