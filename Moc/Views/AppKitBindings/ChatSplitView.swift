//
//  ChatSplitView.swift
//  Moc
//
//  Created by Егор Яковенко on 07.01.2022.
//

import SwiftUI

struct ChatSplitView: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> NSViewControllerType {
        let storyboard = NSStoryboard(name: "ChatSplitView", bundle: Bundle.main)
        let viewController = storyboard.instantiateController(withIdentifier: "Root") as! NSViewController
        return viewController
    }

    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {

    }

    typealias NSViewControllerType = NSViewController
}

struct ChatSplitView_Previews: PreviewProvider {
    static var previews: some View {
        ChatSplitView()
    }
}
