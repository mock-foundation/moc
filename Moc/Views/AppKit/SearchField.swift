//
//  SearchField.swift
//  Moc
//
//  Created by Егор Яковенко on 26.12.2021.
//

import SwiftUI

struct SearchField: NSViewRepresentable {    
    func makeNSView(context _: Context) -> NSViewType {
        return NSSearchField()
    }

    func updateNSView(_: NSViewType, context _: Context) {}

    typealias NSViewType = NSSearchField
}
