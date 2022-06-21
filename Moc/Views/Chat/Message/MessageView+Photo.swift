//
//  MessageView+Photo.swift
//  Moc
//
//  Created by Егор Яковенко on 21.06.2022.
//

import SwiftUI
import TDLibKit

extension MessageView {
    // swiftlint:disable function_body_length cyclomatic_complexity
    func makeMessagePhoto(from info: MessagePhoto) -> some View {
        makeMessage {
            VStack(spacing: 0) {
                // NOTE: all of this code is only for macOS Monterey
                // and iPadOS 15. It's a subject for change when I will
                // get familiar with new Layout API in macOS Ventura
                // and iPadOS 16, so I can build a better system for
                // organizing media in an album
                switch message.count { // go through all possible cases of media count in an album
                    case 1:
                        makeImage(from: getPhoto(from: message[0].content)!)
                    case 2:
                        HStack(spacing: 1) {
                            makeImage(from: getPhoto(from: message[0].content)!)
                            makeImage(from: getPhoto(from: message[1].content)!)
                        }
                    case 3:
                        HStack(spacing: 1) {
                            makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                            VStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                            }.frame(maxWidth: 100)
                        }
                    case 4:
                        VStack(spacing: 1) {
                            makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[3].content)!, contentMode: .fill)
                            }
                        }
                    case 5:
                        VStack(spacing: 1) {
                            makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[3].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[4].content)!, contentMode: .fill)
                            }
                        }
                    case 6:
                        VStack(spacing: 1) {
                            makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[3].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[4].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[5].content)!, contentMode: .fill)
                            }
                        }
                    case 7:
                        VStack(spacing: 1) {
                            makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[3].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[4].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[5].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[6].content)!, contentMode: .fill)
                            }
                        }
                    case 8:
                        VStack(spacing: 1) {
                            makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                            makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[3].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[4].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[5].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[6].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[7].content)!, contentMode: .fill)
                            }
                        }
                    case 9:
                        VStack(spacing: 1) {
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[3].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[4].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[5].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[6].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[7].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[8].content)!, contentMode: .fill)
                            }
                        }
                    case 10:
                        VStack(spacing: 1) {
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[0].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[1].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[2].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[3].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[4].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[5].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[6].content)!, contentMode: .fill)
                            }
                            HStack(spacing: 1) {
                                makeImage(from: getPhoto(from: message[7].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[8].content)!, contentMode: .fill)
                                makeImage(from: getPhoto(from: message[9].content)!, contentMode: .fill)
                            }
                        }
                    default:
                        Image(systemName: "xmark")
                            .font(.system(size: 22))
                }
                
                if !info.caption.text.isEmpty {
                    Text(info.caption.text)
                        .if(message.first!.isOutgoing) { view in
                            view.foregroundColor(.white)
                        }
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
            }
            .sheet(item: $openedMediaFileID) { omfid in
                ZStack {
                    AsyncTdQuickLookView(id: omfid.id) {
                        ProgressView()
                    }
                    Button {
                        openedMediaFileID = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.escape, modifiers: [])
                    .background(.ultraThinMaterial, in: Circle())
                    .clipShape(Circle())
#if os(macOS)
                    .hTrailing()
#elseif os(iOS)
                    .hLeading()
#endif
                    .vTop()
                    .padding()
                }
#if os(macOS)
                .frame(width: 800, height: 600)
#endif
            }
        }
    }
}
