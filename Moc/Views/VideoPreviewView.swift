//
//  VideoPreviewView.swift
//  Moc
//
//  Created by Егор Яковенко on 25.06.2022.
//

import SwiftUI
import AVKit

struct VideoPreviewView: View {
    let path: String
    
    let player: AVPlayer
    
    init(path: String) {
        self.path = path
        self.player = AVPlayer(url: URL(fileURLWithPath: path))
    }
    
    var body: some View {
        PlayerView(player: player)
            .onAppear {
                player.play()
            }
    }
}
