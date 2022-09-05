//
//  ChatViewModel+Utils.swift
//  Moc
//
//  Created by Егор Яковенко on 08.07.2022.
//

import SwiftUI

extension ChatViewModel {
    func scrollToEnd() {
        withAnimation(.fastStartSlowStop()) {
            scrollViewProxy?.scrollTo(messages.last?.first?.id ?? 0, anchor: .center)
        }
    }
    
    func scrollToMessage(at id: Int64) {
        highlightMessage(at: id)
        withAnimation(.fastStartSlowStop()) {
            scrollViewProxy?.scrollTo(id, anchor: .center)
        }
    }
    
    func highlightMessage(at id: Int64) {
        highlightedMessageId = id
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.highlightedMessageId = nil
        }
    }
}
