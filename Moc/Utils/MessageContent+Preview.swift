//
//  MessageContent+Preview.swift
//  Moc
//
//  Created by Егор Яковенко on 05.07.2022.
//

import TDLibKit
import SwiftUI
import Utilities

extension MessageContent {
    private func makeLabel(_ caption: String, icon: String) -> some View {
        Label(caption, systemImage: icon)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(1)
    }
    
    @ViewBuilder
    var preview: some View {
        switch self {
            case let .messageText(info):
                Text(info.text.text)
            case let .messagePhoto(info):
                makeLabel(info.caption.text, icon: "photo")
            case let .messageVideo(info):
                makeLabel(info.caption.text, icon: "video")
            case let .messageDocument(info):
                makeLabel(info.caption.text, icon: "doc.text")
            default:
                Text(Constants.unsupportedMessageString)
        }
    }
}
