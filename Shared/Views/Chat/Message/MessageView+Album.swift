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
                    switch message.count { // go through all possible cases of media count in an album
                        // TODO: these grids are shit
                        case 1:
                            makeMedia(from: message[0].content)
                        case 2:
                            LazyVGrid(columns: [GridItem(), GridItem()]) {
                                makeMedia(from: message[0].content)
                                makeMedia(from: message[1].content)
                            }
                        case 3:
                            LazyVGrid(columns: [GridItem(), GridItem()]) {
                                makeMedia(from: message[0].content)
                                VStack {
                                    makeMedia(from: message[1].content)
                                    makeMedia(from: message[2].content)
                                }
                            }
                        case 4:
                            LazyVGrid(columns: [GridItem(), GridItem()]) {
                                ForEach(0..<4) { index in
                                    makeMedia(from: message[index].content)
                                }
                            }
                        case 5:
                            LazyHGrid(rows: [GridItem(), GridItem()]) {
                                HStack {
                                    makeMedia(from: message[0].content)
                                    makeMedia(from: message[1].content)
                                }
                                HStack {
                                    makeMedia(from: message[2].content)
                                    makeMedia(from: message[3].content)
                                    makeMedia(from: message[4].content)
                                }
                            }
                        case 6:
                            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                                ForEach(0..<6) { index in
                                    makeMedia(from: message[index].content)
                                }
                            }
                        case 7:
                            LazyHGrid(rows: [GridItem(), GridItem(), GridItem()]) {
                                HStack {
                                    makeMedia(from: message[0].content)
                                    makeMedia(from: message[1].content)
                                }
                                HStack {
                                    makeMedia(from: message[2].content)
                                    makeMedia(from: message[3].content)
                                }
                                HStack {
                                    makeMedia(from: message[4].content)
                                    makeMedia(from: message[5].content)
                                    makeMedia(from: message[6].content)
                                }
                            }
                        case 8:
                            LazyHGrid(rows: [GridItem(), GridItem(), GridItem()]) {
                                HStack {
                                    makeMedia(from: message[0].content)
                                    makeMedia(from: message[1].content)
                                }
                                HStack {
                                    makeMedia(from: message[2].content)
                                    makeMedia(from: message[3].content)
                                    makeMedia(from: message[4].content)
                                }
                                HStack {
                                    makeMedia(from: message[5].content)
                                    makeMedia(from: message[6].content)
                                    makeMedia(from: message[7].content)
                                }
                            }
                        case 9:
                            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                                ForEach(0..<9) { index in
                                    makeMedia(from: message[index].content)
                                }
                            }
                        case 10:
                            LazyHGrid(rows: [GridItem(), GridItem(), GridItem()]) {
                                HStack {
                                    makeMedia(from: message[0].content)
                                    makeMedia(from: message[1].content)
                                    makeMedia(from: message[2].content)
                                }
                                HStack {
                                    makeMedia(from: message[3].content)
                                    makeMedia(from: message[4].content)
                                    makeMedia(from: message[5].content)
                                    makeMedia(from: message[6].content)
                                }
                                HStack {
                                    makeMedia(from: message[7].content)
                                    makeMedia(from: message[8].content)
                                    makeMedia(from: message[9].content)
                                }
                            }
                        default:
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.gray.opacity(0.4))
                                .skeleton(with: true)
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
