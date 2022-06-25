//
//  PlayerView.swift
//  Moc
//
//  Created by Егор Яковенко on 25.06.2022.
//

import SwiftUI
import AVKit

struct PlayerView: NSViewRepresentable {
    let player: AVPlayer
    
    func makeNSView(context: Context) -> PlayerLayerView {
        return PlayerLayerView(player: player)
    }
    
    func updateNSView(_ nsView: PlayerLayerView, context: Context) { }
}
