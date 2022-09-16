//
//  MediaAlbum.swift
//  Moc
//
//  Created by Егор Яковенко on 16.09.2022.
//

import SwiftUI

// swiftlint:disable line_length
// TODO: Finish this

/// This layout works (at least it should) and functions the same as in the
/// Telegram iOS client, just because the layout logic was sto- i mean
/// borrowed from it's code
/// 
/// https://github.com/TelegramMessenger/Telegram-iOS/blob/master/submodules/MosaicLayout/Sources/ChatMessageBubbleMosaicLayout.swift
@available(macOS 13, iOS 16, *)
struct MediaAlbum: Layout {
    // swiftlint:enable line_length
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        .zero
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        
    }
}

@available(macOS 13, iOS 16, *)
extension MediaAlbum {
    struct ItemPosition: OptionSet {
        public var rawValue: Int32
        
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
        
        public static let top = ItemPosition(rawValue: 1)
        public static let bottom = ItemPosition(rawValue: 2)
        public static let left = ItemPosition(rawValue: 4)
        public static let right = ItemPosition(rawValue: 8)
        public static let inside = ItemPosition(rawValue: 16)
        public static let unknown = ItemPosition(rawValue: 65536)
        
        public var isWide: Bool {
            return self.contains(.left) && self.contains(.right) && (self.contains(.top) || self.contains(.bottom))
        }
    }
    
    struct ItemInfo {
        let index: Int
        let imageSize: CGSize
        let aspectRatio: CGFloat
        
        var layoutFrame: CGRect = CGRect()
        var position: ItemPosition = []
    }
    
    struct LayoutAttempt {
        let lineCounts: [Int]
        let heights: [CGFloat]
    }
}
