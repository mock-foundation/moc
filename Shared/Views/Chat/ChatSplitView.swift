//
//  ChatSplitView.swift
//  Moc
//
//  Created by Егор Яковенко on 07.01.2022.
//

import SwiftUI

// TODO: Rewrite this mess with usage of the detail column of Navigation(Split)View

struct ChatSplitView<Left: View, Right: View>: View {
    var isRightViewVisible: Bool = true
    @ViewBuilder var leftView: () -> Left
    @ViewBuilder var rightView: () -> Right
    
    @ViewBuilder
    private var content: some View {
        leftView()
        if isRightViewVisible {
            HStack {
                Divider()
                    .frame(width: 2)
                rightView()
                    .frame(width: 256)
            }
            .transition(.move(edge: .trailing))
        }
    }

    var body: some View {
        HStack { content }
            .animation(.fastStartSlowStop(0.4), value: isRightViewVisible)
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
