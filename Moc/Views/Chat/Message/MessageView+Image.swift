//
//  MessageView+Image.swift
//  Moc
//
//  Created by Егор Яковенко on 21.06.2022.
//

import SwiftUI
import TDLibKit

extension MessageView {
    func makeImage(from info: MessagePhoto, contentMode: ContentMode = .fit) -> some View {
        ZStack {
            AsyncTdImage(
                id: info.photo.sizes[info.photo.sizes.endIndex - 1].photo.id
            ) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } placeholder: {
                ProgressView()
            }
        }
        .frame(minWidth: 0, maxWidth: 350, minHeight: 0, maxHeight: 200)
        .background {
            AsyncTdImage(
                id: info.photo.sizes[info.photo.sizes.endIndex - 1].photo.id
            ) { image in
                image
                    .resizable()
            } placeholder: {
                ProgressView()
            }.overlay {
                Color.clear
                    .background(.ultraThinMaterial, in: Rectangle())
            }
        }
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .circular))
        .onTapGesture {
            openedMediaFileID = OMFID(id: info.photo.sizes[info.photo.sizes.endIndex - 1].photo.id)
        }
        .onDrag {
            if #available(macOS 13.0, *) {
                return NSItemProvider(object: NSImage(contentsOfFile: info.photo.sizes[info.photo.sizes.endIndex - 1].photo.local.path)!)
            } else {
                return NSItemProvider(object: NSURL(fileURLWithPath: info.photo.sizes[info.photo.sizes.endIndex - 1].photo.local.path))
            }
        }
    }
}
