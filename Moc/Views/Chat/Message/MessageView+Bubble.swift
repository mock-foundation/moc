//
//  MessageView+Bubble.swift
//  Moc
//
//  Created by Егор Яковенко on 21.06.2022.
//

import SwiftUI

struct MessageBubbleView<Content: View, ReplyContent: View>: View {
    let isOutgoing: Bool
    @ViewBuilder let content: () -> Content
    let replyContent: (() -> ReplyContent)?
    
    init(
        isOutgoing: Bool = false,
        content: @escaping () -> Content,
        replyContent: (() -> ReplyContent)? = nil
    ) {
        self.isOutgoing = isOutgoing
        self.content = content
        self.replyContent = replyContent
    }
    
    @State private var width: CGFloat = 50
    
    var body: some View {
        VStack(alignment: .leading) {
            if let replyContent = replyContent {
                replyContent()
                    .padding(8)
                    .padding(.bottom, 20)
//                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.gray))
//                    .frame(width: width)
                    .frame(maxHeight: 40)
                    .padding(.leading, 4)
            }
            content()
                .if(!isOutgoing) {
                    $0.padding(.leading, 7)
                }
                .background {
                    if isOutgoing {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .foregroundColor(Color("MessageFromMeColor"))
                    } else {
                        Image("ChatMessageBubbleRecipient")
                            .resizable(capInsets: EdgeInsets(
                                top: 18,
                                leading: 18,
                                bottom: 18,
                                trailing: 18
                            ), resizingMode: .stretch)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .foregroundColor(Color("MessageFromRecepientColor"))
                    }
                }
                .if(replyContent != nil) {
                    $0.padding(.top, -12)
                }
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onChange(of: proxy.size) {
                                self.width = $0.width
                            }
                            .onAppear {
                                print(proxy.size.width, proxy.size.height)
                            }
                    }
                }
        }
    }
}

extension MessageView {
    func makeMessageBubble<Content: View, ReplyContent: View>(
        isOutgoing: Bool = false,
        @ViewBuilder _ content: @escaping () -> Content,
        replyContent: (() -> ReplyContent)? = nil
    ) -> some View {
        MessageBubbleView(isOutgoing: isOutgoing, content: content, replyContent: replyContent)
    }
}
