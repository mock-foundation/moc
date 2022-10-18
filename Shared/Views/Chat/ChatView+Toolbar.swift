//
//  ChatView+Toolbar.swift
//  Moc
//
//  Created by Егор Яковенко on 08.07.2022.
//

import SwiftUI

extension ChatView {
    var toolbar: some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .navigation) {
                Button {
                    isChatInfoShown = true
                } label: {
                    HStack {
                        // Chat photo
                        if let photo = viewModel.chatPhoto {
                            AsyncTdImage(id: photo.id) { image in
                                image
                                    .resizable()
                                    .interpolation(.medium)
                                    .antialiased(true)
                            } placeholder: {
                                makePlaceholder(.small)
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        } else {
                            makePlaceholder(.small)
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                        }
                        // Chat title and quick info
                        VStack(alignment: .leading) {
                            Text(viewModel.chatTitle)
                                .font(.headline)
                            Text("Chat subtitle")
                                .font(.subheadline)
                        }
                    }
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $isChatInfoShown) {
                    ChatInspector(id: viewModel.chatID)
                        .frame(minWidth: 700, minHeight: 500)
                        .overlay(alignment: .topLeading) {
                            Button {
                                isChatInfoShown = false
                            } label: {
                                Image(systemName: "xmark")
                            }
                            .buttonStyle(.plain)
                            .padding(12)
                        }
                }
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    print("search")
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                Button { viewModel.isInspectorShown.toggle() } label: {
                    Image(systemName: "sidebar.right")
                }
                Button {
                    print("more")
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}
