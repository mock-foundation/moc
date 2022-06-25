//
//  AVPlayerViewWrapper.swift
//  Moc
//
//  Created by Егор Яковенко on 25.06.2022.
//

import SwiftUI
import Utilities
import Combine
import AVKit

class AVPlayerViewWithoutMouseDown: AVPlayerView {
    override func mouseDown(with event: NSEvent) {
        self.nextResponder?.mouseDown(with: event)
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return self
    }
}

struct AVPlayerViewWrapper: NSViewRepresentable {
    let path: String
    
    private var player: AVPlayer
    
    init(path: String) {
        self.path = path
        self.player = AVPlayer(url: URL(fileURLWithPath: path))
    }
            
    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerViewWithoutMouseDown()
        view.showsFullScreenToggleButton = true
        player.actionAtItemEnd = .none
        view.controlsStyle = .none
        view.player = player
        view.delegate = context.coordinator
        
        player.play()
                
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(player: player)
    }
    
    class Coordinator: NSObject, AVPlayerViewDelegate {
        private let player: AVPlayer
        
        private var cancellables: [AnyCancellable] = []
        
        init(player: AVPlayer) {
            self.player = player
            
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { notification in
                if let playerItem = notification.object as? AVPlayerItem {
                    playerItem.seek(to: .zero, completionHandler: nil)
                }
            }
        }
        
        func playerViewWillEnterFullScreen(_ playerView: AVPlayerView) {
            playerView.controlsStyle = .floating
        }
        
        func playerViewWillExitFullScreen(_ playerView: AVPlayerView) {
            playerView.controlsStyle = .none
        }
    }
}
