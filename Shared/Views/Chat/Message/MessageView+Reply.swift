//
//  MessageView+Reply.swift
//  Moc
//
//  Created by Егор Яковенко on 04.07.2022.
//

import SwiftUI
import TDLibKit
import Utilities

extension MessageView {
    private func makePreviewLabel(_ caption: String, icon: String) -> some View {
        Label(caption, systemImage: icon)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(1)
    }

    @ViewBuilder
    func replyLabel(reply: ReplyMessage) -> some View {
        HStack {
            Capsule()
                .if(mainMessage.isOutgoing) {
                    $0.fill(.white)
                } else: {
                    $0.fill(self.replyUsernameColor?.withLuminosity(colorSchemeContrast) ?? .white)
                }
                .frame(width: 3)
            VStack(alignment: .leading) {
                Text("\(reply.sender.firstName) \(reply.sender.lastName != nil ? "\(reply.sender.lastName!)" : "")")
                    .if(mainMessage.isOutgoing) {
                        $0.foregroundColor(.white)
                    } else: {
                        $0.foregroundColor(self.replyUsernameColor?.withLuminosity(colorSchemeContrast) ?? .white)
                    }
                Group {
                    switch reply.content {
                        case let .text(info):
                            Text(info.text.text)
                        case let .photo(info):
                            makePreviewLabel(info.caption.text, icon: "photo")
                        case let .video(info):
                            makePreviewLabel(info.caption.text, icon: "video")
                        case let .document(info):
                            makePreviewLabel(info.caption.text, icon: "doc.text")
                        default:
                            Text(Constants.unsupportedMessage)
                    }
                }
                .if(mainMessage.isOutgoing) {
                    $0.foregroundColor(.white.darker(by: 50))
                }
                .if(!mainMessage.isOutgoing) {
                    $0.foregroundStyle(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    var replyView: some View {
        if let reply = message.first!.replyToMessage {
            Button {
                SystemUtils.post(notification: .scrollToMessage, with: reply.id)
            } label: {
                replyLabel(reply: reply)
            }
            .buttonStyle(.plain)
            .frame(height: 30)
            .onAppear {
                guard let reply = message.first!.replyToMessage else { return }
                Task {
                    let replyUserId = reply.sender.id
                    self.replyUsernameColor = try await Color(from: replyUserId) ?? Color(fromUserId: replyUserId)
                }
            }
        }
    }
}
