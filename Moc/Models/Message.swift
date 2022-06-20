//
//  Message.swift
//
//
//  Created by Егор Яковенко on 01.02.2022.
//

import Foundation
import TDLibKit

struct Message: Identifiable, Hashable, Equatable {
    let id: Int64
    let sender: MessageSender
    let content: MessageContent
    let isOutgoing: Bool
    let date: Foundation.Date
    let mediaAlbumID: Int64
}
