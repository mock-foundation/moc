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
                    Button {
                        
                    } label: {
                        Text("Save to Downloads")
                    }
                }.frame(maxHeight: 30)
                Spacer()
            }
        }
    }
    
    func makeMessageDocument(from info: MessageDocument) -> some View {
        makeMessage {
            makeDocument(from: info)
                .padding(8)
        }
    }
}
