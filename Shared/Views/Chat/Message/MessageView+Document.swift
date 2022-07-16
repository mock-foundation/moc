//
//  MessageView+Document.swift
//  Moc
//
//  Created by Егор Яковенко on 30.06.2022.
//

import SwiftUI
import TDLibKit
import SkeletonUI

extension MessageView {
    func makeDocument(from info: MessageDocument) -> some View {
        MessageDocumentView(info: info)
    }
    
    func makeMessageDocument(from info: MessageDocument) -> some View {
        makeMessage {
            makeDocument(from: info)
                .padding(8)
        }
    }
}

struct MessageDocumentView: View {
    let info: MessageDocument
    
    @State private var showingSavedToDownloadsCheckmark = false
    
    var body: some View {
        HStack(spacing: 8) {
            AsyncTdImage(id: info.document.document.id) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .skeleton(with: true)
                    .shape(type: .rounded(.radius(8, style: .continuous)))
            }
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.white)
            }
            .frame(maxWidth: 70, maxHeight: 70)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                Text(info.document.fileName)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(2)
                    .truncationMode(.middle)
                    .foregroundColor(.white)
                HStack {
                    Text("\(info.document.document.size / 1024) KB")
                        .foregroundColor(.white)
                    Divider()
                    if showingSavedToDownloadsCheckmark {
                        Image(systemName: "checkmark.circle")
                            .transition(.move(edge: .leading))
                    }
                    Button {
                        try? FileManager.default.copyItem(
                            at: URL(fileURLWithPath: info.document.document.local.path),
                            to: FileManager.default.urls(
                                for: .downloadsDirectory,
                                in: .userDomainMask)[0].appendingPathComponent(info.document.fileName))
                        showingSavedToDownloadsCheckmark = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showingSavedToDownloadsCheckmark = false
                        }
                    } label: {
                        Text("Save to Downloads")
                    }
                    .animation(.easeOut, value: showingSavedToDownloadsCheckmark)
                }.frame(maxHeight: 30)
                Spacer()
            }
        }
    }
}
