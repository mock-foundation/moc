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
    
    struct OMFID: Identifiable {
        let id: Int
    }
    @State var openedMediaFileID: OMFID?
    @State var senderPhotoFileID: Int?
    
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
            switch message.first!.content {
                case let .messageText(info):
                    makeMessage {
                        VStack(alignment: .leading) {
                            if !message.first!.isOutgoing {
                                Text(message.first!.sender.name)
                                    .foregroundColor(Color(fromUserId: message.first!.sender.id))
                            }
                            Text(info.text.text)
                                .textSelection(.enabled)
                                .if(message.first!.isOutgoing) { view in
                                    view.foregroundColor(.white)
                                }
                        }.padding(8)
                    }
                case let .messagePhoto(info):
                    makeMessagePhoto(from: info)
                case .messageUnsupported:
                    makeMessage {
                        Text("Sorry, this message is unsupported.")
                            .if(message.first!.isOutgoing) { view in
                                view.foregroundColor(.white)
                            }
                            .padding(8)
                    }
                default:
                    makeMessage {
                        Text("Sorry, this message is unsupported.")
                            .if(message.first!.isOutgoing) { view in
                                view.foregroundColor(.white)
                            }
                            .padding(8)
                    }
            }
        }
        .if(message.first!.isOutgoing) { view in
            view.padding(.trailing)
        } else: { view in
            view.padding(.leading, 6)
        }
    }
}
