//
//  VisualEffect.swift
//  Moc
//
//  Created by Егор Яковенко on 19.08.2022.
//

import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material?
    
    func makeNSView(context: Self.Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        if let material {
            view.material = material
        }

        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        if let material {
            nsView.material = material
        }
    }
}
