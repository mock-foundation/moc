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
    
    var body: some View {
        PlayerView(player: AVPlayer(url: URL(fileURLWithPath: path)))
    }
}
