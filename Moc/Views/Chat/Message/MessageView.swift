//
//  MessageView.swift
//  Moc
//
//  Created by Егор Яковенко on 26.02.2022.
//

import SwiftUI
import TDLibKit
import Logs
import Utilities

struct MessageView: View {
    @State var message: [Moc.Message]
    
    // Internal state
    
    struct OpenedMediaFile: Identifiable {
        let id: Int
        let isVideo: Bool
        
        init(id: Int, isVideo: Bool = false) {
            self.id = id
            self.isVideo = isVideo
        }
    }
    
    @State var openedMediaFileID: OpenedMediaFile?
    @State var senderPhotoFileID: Int?
    // swiftlint:disable orphaned_doc_comment
    /// Download progress of a media file, represented by a tuple of current progress and overall size
//    @State var downloadProgress: (Int64?, Int64)?
    
    let tdApi = TdApi.shared[0]
    let logger = Logger(category: "MessageView", label: "UI")
    
    var avatarPlaceholder: some View {
        ProfilePlaceholderView(
            userId: message.first!.sender.id,
            firstName: message.first!.sender.firstName,
            lastName: message.first!.sender.lastName ?? "",
            style: .miniature)
    }

    @ViewBuilder
    var body: some View {
        Group {
            if message.count > 1 {
                makeAlbum()
            } else {
                switch message.first!.content {
                    case let .messageText(info):
                        makeMessage {
                            VStack(alignment: .leading) {
                                HStack {
                                    Capsule()
                                        .frame(width: 3)
                                    VStack(alignment: .leading) {
                                        Text("Sender")
                                        Text("Message content")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(height: 30)
                                .padding(.top, 8)
                                if !message.first!.isOutgoing {
                                    Text(message.first!.sender.name)
                                        .foregroundColor(Color(fromUserId: message.first!.sender.id))
                                }
                                Text(info.text.text)
                                    .textSelection(.enabled)
                                    .if(message.first!.isOutgoing) { view in
                                        view.foregroundColor(.white)
                                    }
                            }
                            .padding([.horizontal, .bottom], 8)
                        }
                    case let .messagePhoto(info):
                        makeMessagePhoto(from: info)
                    case let .messageVideo(info):
                        makeMessageVideo(from: info)
                    case let .messageDocument(info):
                        makeMessageDocument(from: info)
                    case .messageUnsupported:
                        makeMessage {
                            Text("Sorry, this message is unsupported.")
                                .if(message.first!.isOutgoing) { view in
                                    view.foregroundColor(.white)
                                }
                                .padding([.horizontal, .bottom], 8)
                        }
                    default:
                        makeMessage {
                            Text("Sorry, this message is unsupported.")
                                .if(message.first!.isOutgoing) { view in
                                    view.foregroundColor(.white)
                                }
                                .padding([.horizontal, .bottom], 8)
                        }
                }
            }
        }
        .sheet(item: $openedMediaFileID) { file in
            ZStack {
                if file.isVideo {
                    AsyncTdVideoPlayer(id: file.id)
                } else {
                    AsyncTdQuickLookView(id: file.id)
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
        .if(message.first!.isOutgoing) { view in
            view.padding(.trailing)
        } else: { view in
            view.padding(.leading, 6)
        }
    }
}
