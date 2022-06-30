//
//  MessageView+Document.swift
//  Moc
//
//  Created by Егор Яковенко on 30.06.2022.
//

import SwiftUI
import TDLibKit
import SkeletonUI

extension MessageView {
    func makeDocument(from info: MessageDocument) -> some View {
        MessageDocumentView(info: info)
    }
    
    func makeMessageDocument(from info: MessageDocument) -> some View {
        makeMessage {
            makeDocument(from: info)
                .padding(8)
        }
    }
}
