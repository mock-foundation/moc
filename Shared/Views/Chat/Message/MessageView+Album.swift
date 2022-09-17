//
//  MessageView+Album.swift
//  Moc
//
//  Created by Егор Яковенко on 24.06.2022.
//

import SwiftUI
import TDLibKit
import SkeletonUI

extension MessageView {
    // swiftlint:disable function_body_length cyclomatic_complexity
    /// Just makes the album. Used in ``makeMessageVideo(from:)``
    /// and ``makeMessagePhoto(from:)`` to not repeate the same code twice
    func makeAlbum() -> some View {
        makeMessage {
            VStack(spacing: 0) {
                // NOTE: all of this code is only for macOS Monterey
                // and iPadOS 15. It's a subject for change when I will
                // get familiar with new Layout API in macOS Ventura
                // and iPadOS 16, so I can build a better system for
                // organizing media in an album
                if message.first(where: { $0.content.isGraphic }) != nil {
                    if #available(macOS 13, iOS 16, *) {
                        MediaAlbum {
                            ForEach(message, id: \.id) { albumMessage in
                                makeMedia(from: albumMessage.content)
                            }
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        HStack {
                            ForEach(message, id: \.id) { message in
                                makeMedia(from: message.content)
                            }
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(message) { msg in
                            makeMedia(from: msg.content)
                        }
                    }.padding(8)
                }

                if !getCaption(from: message.first!.content).text.isEmpty {
                    makeText(for: getCaption(from: message.first!.content))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
            }
        }
    }
}
