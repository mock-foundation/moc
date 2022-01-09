//
//  SearchField.swift
//  Moc
//
//  Created by Егор Яковенко on 26.12.2021.
//

import SwiftUI

struct SearchField: NSViewRepresentable {
	func makeNSView(context: Context) -> NSSearchField {
		let view = NSSearchField()
		return view
	}
	
	func updateNSView(_ nsView: NSSearchField, context: Context) {
		
	}
	
	typealias NSViewType = NSSearchField
}
