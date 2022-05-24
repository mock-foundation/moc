//
//  SearchField.swift
//  Moc
//
//  Created by Егор Яковенко on 26.12.2021.
//

import SwiftUI

struct SearchField: NSViewRepresentable {
    func makeNSView(context _: Context) -> NSViewType {
        let view = NSSearchField()
        view.controlSize = .large
        return view
    }

    func updateNSView(_: NSViewType, context _: Context) {}

    typealias NSViewType = NSSearchField
}
