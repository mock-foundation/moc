//
//  SearchField.swift
//  Moc
//
//  Created by Егор Яковенко on 26.12.2021.
//

import SwiftUI

struct SearchField: NSViewRepresentable {
    func makeNSView(context _: Context) -> NSSearchField {
        let view = NSSearchField()
        return view
    }

    func updateNSView(_: NSSearchField, context _: Context) {}

    typealias NSViewType = NSSearchField
}
