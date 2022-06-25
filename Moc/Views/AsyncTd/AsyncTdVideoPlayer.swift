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
import AVFoundation

struct AsyncTdVideoPlayer: View {
    let id: Int
    
    var body: some View {
        AsyncTdFile(id: id) { file in
            AVPlayerViewWrapper(
                path: file.local.path,
                controlsStyle: .none)
        } placeholder: {
            ProgressView()
        }
    }
}
