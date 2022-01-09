//
//  ChatSplitView.swift
//  Moc
//
//  Created by Егор Яковенко on 07.01.2022.
//

import SwiftUI

struct ChatSplitView<Left, Right>: NSViewRepresentable where Left: View, Right: View {
    typealias NSViewType = NSSplitView
    @ViewBuilder var leftView: () -> Left
    @ViewBuilder var rightView: () -> Right
    var isRightViewVisible: Bool = true
    var orientation: Orientation = .horizontal
    var dividerStyle: NSSplitView.DividerStyle = .thin
    
    enum Orientation {
        case vertical
        case horizontal
    }

    func makeNSView(context: Context) -> NSSplitView {
        let nsView = NSSplitView()
        switch orientation {
        // Don't get confused of this part! The isVertical property it for
        // setting the orientation of the divider, so if the divider is vertical,
        // then views are arranged horizontally (left to right). Yea, confusing at first 😅
        case .vertical:
            nsView.isVertical = false
        case .horizontal:
            nsView.isVertical = true
        }
        nsView.addArrangedSubview(NSHostingView(rootView: leftView()))
        nsView.addArrangedSubview(NSHostingView(rootView: rightView()))
        nsView.dividerStyle = dividerStyle
        nsView.setPosition(isRightViewVisible ? nsView.frame.width - 256 : nsView.frame.width, ofDividerAt: 0)
        nsView.layoutSubtreeIfNeeded()

        return nsView
    }

    func updateNSView(_ nsView: NSSplitView, context: Context) {
        nsView.setPosition(isRightViewVisible ? nsView.frame.width - 256 : nsView.frame.width, ofDividerAt: 0)
        nsView.layoutSubtreeIfNeeded()
    }
}

struct ChatSplitView_Previews: PreviewProvider {
    static var previews: some View {
        ChatSplitView(leftView: {
            Text("Left")
        }, rightView: {
            Text("Right")
        })
    }
}
