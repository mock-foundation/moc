//
//  SearchField.swift
//  Moc
//
//  Created by Егор Яковенко on 26.12.2021.
//

import SwiftUI

struct SearchField: NSViewRepresentable {
    func makeNSView(context _: Context) -> NSSearchField {
        return NSSearchField()
    }

    func updateNSView(_: NSSearchField, context _: Context) {}
}
