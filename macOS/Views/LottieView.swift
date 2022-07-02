//
//  LottieView.swift
//  Moc
//
//  Created by Егор Яковенко on 03.01.2022.
//

import Lottie
import SwiftUI

struct LottieView: NSViewRepresentable {
    var name: String

    func makeNSView(context _: Context) -> NSView {
        let view = NSView(frame: .zero)

        let animationView = AnimationView()
        let animation = Animation.named(name)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        return view
    }

    func updateNSView(_: NSView, context _: Context) {}
}

struct LottieView_Previews: PreviewProvider {
    static var previews: some View {
        LottieView(name: "")
    }
}
