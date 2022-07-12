//
//  URL+Thumbnail.swift
//  
//
//  Created by Егор Яковенко on 29.06.2022.
//

import AVKit
import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
public typealias PlatformImage = NSImage
#elseif os(iOS)
public typealias PlatformImage = UIImage
#endif

public extension URL {
    /// Generated a thumbnail from a URL.
    var thumbnail: Image {
        #if os(macOS)
        Image(nsImage: platformThumbnail)
        #elseif os(iOS)
        Image(uiImage: platformThumbnail)
        #endif
    }

    var platformThumbnail: PlatformImage {
        let fileExtension = self.pathExtension
        let uti = UTType(filenameExtension: fileExtension)
        
        guard let uti = uti else {
            #if os(macOS)
            return NSImage(systemSymbolName: "exclamationmark.circle", accessibilityDescription: nil)!
            #elseif os(iOS)
            return UIImage(systemName: "exclamationmark.circle")!
            #endif
        }
                
        func thumbnailForVideo() -> PlatformImage {
            let asset = AVURLAsset(url: self)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            guard let cgImage = try? imageGenerator.copyCGImage(at: .zero, actualTime: nil) else {
                return PlatformImage()
            }
                        
            #if os(macOS)
            return NSImage(cgImage: cgImage, size: .zero)
            #elseif os(iOS)
            return UIImage(cgImage: cgImage)
            #endif
        }
                
        if uti.conforms(to: .image) {
            return PlatformImage(contentsOfFile: self.filePath!)!
        } else if uti.conforms(toAtLeastOneOf: [
            .video,
            .mpeg4Movie,
            .mpeg2Video,
            .appleProtectedMPEG4Video,
            .quickTimeMovie]
        ) {
            return thumbnailForVideo()
        } else {
            #if os(macOS)
            return NSImage()
            #elseif os(iOS)
            return UIImage()
            #endif
        }
    }
}
