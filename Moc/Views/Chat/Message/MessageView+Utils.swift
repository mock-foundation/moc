//
//  MessageView+Utils.swift
//  Moc
//
//  Created by Егор Яковенко on 21.06.2022.
//

import SwiftUI
import TDLibKit

extension MessageView {
    func getPhoto(from content: MessageContent) -> MessagePhoto? {
        if case .messagePhoto(let info) = content {
            return info
        } else {
            return nil
        }
    }
}
