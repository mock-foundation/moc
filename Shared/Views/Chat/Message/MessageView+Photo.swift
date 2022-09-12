//
//  MessageView+Photo.swift
//  Moc
//
//  Created by Егор Яковенко on 21.06.2022.
//

import SwiftUI
import Backend
import SkeletonUI

extension MessageView {
    // swiftlint:disable function_body_length
    func makePhoto(from info: MessagePhoto, contentMode: ContentMode = .fit) -> some View {
        ZStack {
            if let size = info.photo.sizes.getSize(.yBox) {
                AsyncTdImage(
                    id: size.photo.id
                ) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                } placeholder: {
                    Rectangle()
                        .skeleton(with: true)
                }
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("Failed to find a photo to display :(")
                }
            }
        }
        .frame(minWidth: 0, maxWidth: 350, minHeight: 0, maxHeight: 200)
        .background {
            if let size = info.photo.sizes.getSize(.yBox) {
                AsyncTdImage(
                    id: size.photo.id
                ) { image in
                    image
                        .resizable()
                } placeholder: {
                    Rectangle()
                        .skeleton(with: true)
                }.overlay {
                    Color.clear
                        .background(.ultraThinMaterial, in: Rectangle())
                }
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("Failed to find a photo to display :(")
                }
            }
        }
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .circular))
        .onTapGesture {
            if let id = info.photo.sizes.getSize(.dCrop)?.photo.id {
                openedMediaFileID = OpenedMediaFile(id: id)
            }
        }
        .onDrag {
            if let path = info.photo.sizes.getSize(.dCrop)?.photo.local.path {
                if #available(macOS 13, iOS 16, *) {
                    #if os(macOS)
                    return NSItemProvider(object: NSImage(contentsOfFile: path)!)
                    #elseif os(iOS)
                    return NSItemProvider(object: UIImage(contentsOfFile: path)!)
                    #endif
                } else {
                    return NSItemProvider(object: NSURL(fileURLWithPath: path))
                }
            } else {
                return NSItemProvider() // I think a blank one will work alright
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
