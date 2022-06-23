//
//  MessageView+Album.swift
//  Moc
//
//  Created by Егор Яковенко on 24.06.2022.
//

import SwiftUI
import TDLibKit

extension MessageView {
    
    /// Just makes the album. Used in ``makeMessageVideo(from:)``
    /// and ``makeMessagePhoto(from:)`` to not repeate the same code twice
    func makeAlbum() -> some View {
        EmptyView()
    }
}
