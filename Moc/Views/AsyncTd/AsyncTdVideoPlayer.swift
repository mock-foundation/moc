//
//  AsyncTdVideoPlayer.swift
//  Moc
//
//  Created by Егор Яковенко on 24.06.2022.
//

import SwiftUI
import TDLibKit
import Utilities
import Logs
import AVKit

struct AsyncTdVideoPlayer: View {
    let id: Int
    
    var body: some View {
        AsyncTdFile(id: id) { file in
            VideoPlayer(player: AVPlayer(url: URL(fileURLWithPath: file.local.path)))
        } placeholder: {
            EmptyView()
        }
    }
}
