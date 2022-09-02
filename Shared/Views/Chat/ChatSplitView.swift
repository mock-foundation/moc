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
        rightView()
            .frame(
                minWidth: isRightViewVisible ? 316 : 0,
                idealWidth: isRightViewVisible ? 316 : 0,
                maxWidth: isRightViewVisible ? nil : 0
            )
            #if os(macOS)
            .animation(.easeInOut, value: isRightViewVisible)
            #elseif os(iOS)
            .animation(.easeOut, value: isRightViewVisible)
            #endif
    }

    var body: some View {
        #if os(macOS)
        HSplitView { content }
        #elseif os(iOS)
        HStack { content }
        #endif
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
