//
//  MessageView+Photo.swift
//  Moc
//
//  Created by Егор Яковенко on 21.06.2022.
//

import SwiftUI
import TDLibKit
import SkeletonUI

extension MessageView {
    func makePhoto(from info: MessagePhoto, contentMode: ContentMode = .fit) -> some View {
        ZStack {
            // TODO: Properly use sizes array using thumbnail types
            // https://core.telegram.org/api/files#image-thumbnail-types
            AsyncTdImage(
                id: info.photo.sizes[0].photo.id
            ) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } placeholder: {
                Rectangle()
                    .skeleton(with: true)
            }
        }
        .frame(minWidth: 0, maxWidth: 350, minHeight: 0, maxHeight: 200)
        .background {
            AsyncTdImage(
                id: info.photo.sizes[0].photo.id
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
            openedMediaFileID = OpenedMediaFile(id: info.photo.sizes[info.photo.sizes.endIndex - 1].photo.id)
        }
        .onDrag {
            let path = info.photo.sizes[info.photo.sizes.endIndex - 1].photo.local.path
            if #available(macOS 13.0, *) {
                #if os(macOS)
                return NSItemProvider(object: NSImage(contentsOfFile: path)!)
                #elseif os(iOS)
                return NSItemProvider(object: UIImage(contentsOfFile: path)!)
                #endif
            } else {
                return NSItemProvider(object: NSURL(fileURLWithPath: path))
            }
        }
    }
    
    func makeMessagePhoto(from info: MessagePhoto) -> some View {
        makeMessage {
            VStack(spacing: 0) {
                makePhoto(from: getPhoto(from: message.first!.content)!)
                
                if !info.caption.text.isEmpty {
                    makeText(for: info.caption)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
            }
        }
    }
}
