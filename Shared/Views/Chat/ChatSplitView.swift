//
//  ChatSplitView.swift
//  Moc
//
//  Created by Егор Яковенко on 07.01.2022.
//

import SwiftUI

// TODO: Merge ChatSplitView with ChatView

struct ChatSplitView<Left: View, Right: View>: View {
    var isRightViewVisible: Bool = true
    @ViewBuilder var leftView: () -> Left
    @ViewBuilder var rightView: () -> Right
    
    @ViewBuilder
    private var content: some View {
        leftView()
        if isRightViewVisible {
            HStack(spacing: 0) {
                Divider()
                rightView()
                    .frame(width: 256)
            }
            .transition(.move(edge: .trailing))
        }
    }

    var body: some View {
        HStack(spacing: 0) { content }
            .animation(.spring(), value: isRightViewVisible)
    }
}

struct ChatSplitView_Previews: PreviewProvider {
    static var previews: some View {
        ChatSplitView {
            Text("Left")
        } rightView: {
            Text("Right")
        }
    }
}
