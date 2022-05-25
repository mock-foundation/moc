//
//  SearchField.swift
//  Moc
//
//  Created by Егор Яковенко on 26.12.2021.
//

import SwiftUI

struct SearchField: NSViewRepresentable {
    private var view = NSSearchField()
    
    func makeNSView(context _: Context) -> NSViewType {
        view.cell?.controlSize = .large
        return view
    }

    func updateNSView(_: NSViewType, context _: Context) {}
    
    func controlSize(_ size: NSControl.ControlSize) -> Self {
        view.cell?.controlSize = size
        return self
    }

    typealias NSViewType = NSSearchField
}
