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
    
    let tdApi = TdApi.shared
    let logger = Logger(category: "UI", label: "MessageView")
    
    var avatarPlaceholder: some View {
        ProfilePlaceholderView(
            userId: message.first!.sender.id,
            firstName: message.first!.sender.firstName,
            lastName: message.first!.sender.lastName ?? "",
            style: .miniature)
    }
    
    var mainMessage: Message {
        return message.first!
    }
    
    func makeText(for formattedText: FormattedText) -> some View {
        FormattedTextView(formattedText)
            .textSelection(.enabled)
            .if(mainMessage.isOutgoing) {
                $0.foregroundColor(.white)
            }
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    var body: some View {
        Group {
            if message.count > 1 {
                makeAlbum()
            } else {
                switch mainMessage.content {
                    case let .text(info):
                        makeMessage {
                            VStack(alignment: .leading) {
                                replyView
                                if !mainMessage.isOutgoing && mainMessage.replyToMessage == nil {
                                    Text(mainMessage.sender.name)
                                        .foregroundColor(Color(fromUserId: message.first!.sender.id))
                                }
                                makeText(for: info.text)
                            }
                            .padding(8)
                        }
                    case let .photo(info):
                        makeMessagePhoto(from: info)
                    case let .video(info):
                        makeMessageVideo(from: info)
                    case let .document(info):
                        makeMessageDocument(from: info)
                    case .unsupported:
                        makeMessage {
                            Text(Constants.unsupportedMessage)
                                .if(message.first!.isOutgoing) { view in
                                    view.foregroundColor(.white)
                                }
                                .padding(8)
                        }
                    default:
                        makeMessage {
                            Text(Constants.unsupportedMessage)
                                .if(message.first!.isOutgoing) { view in
                                    view.foregroundColor(.white)
                                }
                                .padding(8)
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
        }
        .if(!mainMessage.isOutgoing) {
            $0.padding(.leading, 6)
        }
    }
}
