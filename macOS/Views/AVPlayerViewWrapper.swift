//
//  AVPlayerViewWrapper.swift
//  Moc
//
//  Created by Егор Яковенко on 25.06.2022.
//

import SwiftUI
import AVKit

struct AVPlayerViewWrapper: NSViewRepresentable {
    let path: String
    let controlsStyle: AVPlayerViewControlsStyle
    
    private let player: AVQueuePlayer
    
    init(path: String, controlsStyle: AVPlayerViewControlsStyle = .default) {
        self.path = path
        self.controlsStyle = controlsStyle
        self.player = AVQueuePlayer(url: URL(fileURLWithPath: path))
    }
    
    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.showsFullScreenToggleButton = true
        view.controlsStyle = controlsStyle
        view.player = player
                
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.controlsStyle = controlsStyle
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(player: player)
    }
    
    class Coordinator: NSObject {
        private var player: AVQueuePlayer?
        private var playerLooper: AVPlayerLooper?
        
        init(player: AVQueuePlayer) {
            self.player = player
            let item = player.currentItem!
            
            playerLooper = AVPlayerLooper(player: self.player!, templateItem: item)
            
            self.player?.play()
        }
    }
}
