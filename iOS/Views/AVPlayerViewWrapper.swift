//
//  AVPlayerViewWrapper.swift
//  Moc
//
//  Created by Егор Яковенко on 27.06.2022.
//

import SwiftUI
import Utilities
import AVKit

struct AVPlayerViewWrapper: UIViewControllerRepresentable {
    let path: String
    
    private var player: AVPlayer
    
    init(path: String) {
        self.path = path
        self.player = AVPlayer(url: URL(fileURLWithPath: path))
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let vc = AVPlayerViewController()
        vc.player = player
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        self.player.replaceCurrentItem(
            with: AVPlayerItem(url: URL(fileURLWithPath: path)))
    }
}
