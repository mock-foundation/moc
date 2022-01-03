//
//  LottieView.swift
//  Moc
//
//  Created by Егор Яковенко on 03.01.2022.
//

import SwiftUI
import Lottie

struct LottieView: NSViewRepresentable {
    typealias NSViewType = NSView

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)

        let animationView = AnimationView()
        let animation = Animation.named(filename)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {  }

    var filename: String
}

struct LottieView_Previews: PreviewProvider {
    static var previews: some View {
        LottieView(filename: "")
    }
}
