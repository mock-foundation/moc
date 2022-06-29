//
//  AVPlayerViewWrapper.swift
//  Moc
//
//  Created by Егор Яковенко on 25.06.2022.
//

import SwiftUI
import Utilities
import AVKit

struct AVPlayerViewWrapper: NSViewRepresentable {
    let path: String
    
    private var player: AVPlayer
    
    init(path: String) {
        self.path = path
        self.player = AVPlayer(url: URL(fileURLWithPath: path))
    }
            
    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.showsFullScreenToggleButton = true
        view.player = player
        view.player?.isMuted = true
        view.showsSharingServiceButton = true
        view.showsFrameSteppingButtons = true
        view.allowsPictureInPicturePlayback = true
        
        player.play()
                
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) { }
}
