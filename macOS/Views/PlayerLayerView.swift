//
//  PlayerLayerView.swift
//  Moc
//
//  Created by Егор Яковенко on 25.06.2022.
//

import AppKit
import AVFoundation

class PlayerLayerView: NSView {
    private let playerLayer = AVPlayerLayer()
    private var player: AVPlayer? = nil

    required public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }
    
    public init(player: AVPlayer) {
        super.init(frame: .infinite)
        self.player = player
        commonInit()
    }
    
    private func commonInit() {
        wantsLayer = true
        
        playerLayer.frame = bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.player = player
        layer?.addSublayer(playerLayer)
        
        player?.play()
    }
}
