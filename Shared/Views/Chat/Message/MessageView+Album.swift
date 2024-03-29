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
    /// Just makes the album. Used in ``makeMessageVideo(from:)``
    /// and ``makeMessagePhoto(from:)`` to not repeate the same code twice
    func makeAlbum() -> some View {
        makeMessage {
            VStack(spacing: 0) {
                if message.first(where: { $0.content.isGraphic }) != nil {
                    MediaAlbum {
                        ForEach(message, id: \.id) { albumMessage in
                            makeMedia(from: albumMessage.content)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
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
