//
//  VisualEffect.swift
//  Moc
//
//  Created by Егор Яковенко on 19.08.2022.
//

import SwiftUI

struct VisualEffect: NSViewRepresentable {
    func makeNSView(context: Self.Context) -> NSView {
        let view = NSVisualEffectView()
        view.material = .popover

        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        
    }
}
