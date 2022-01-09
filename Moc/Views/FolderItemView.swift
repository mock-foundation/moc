//
//  FolderItemView.swift
//  Moc
//
//  Created by Егор Яковенко on 25.12.2021.
//

import SwiftUI

struct FolderItemView: View {
	@State private var backgroundColor: Color = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0)
	@State private var selected = false
	private let selectedColor = Color("FolderItemSelectedColor")

//	let onSelect: () -> Void

	func folderItem(item: FolderItem) -> some View {
		VStack {
			item.icon
				.padding(4)
			Text(item.name)
		}
		.padding(.vertical)
		.onHover { isHovered in
			if isHovered {
				backgroundColor = Color("OnHoverColor")
			} else {
				backgroundColor = Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0)
			}
		}
//		.onReceive(
//        NotificationCenter.default.publisher(
//        for: Notification.Name("FolderSelected")
//        ), perform: { notification in
//			print("hey lol")
//			print(notification.object as! Int)
//		})
//		.onReceive(
//        NotificationCenter.default.publisher(
//        for: Notification.Name("FolderDeselected")
//        ), perform: { notification in
//			print("hey lol")
//			print(notification.object as! Int)
//		})
		.frame(width: 64, height: 64)
		.background(selected ? selectedColor : backgroundColor)
		.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
	}

    var body: some View {
		folderItem(item: FolderItem(name: "Name", icon: Image(systemName: "folder")))
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
		FolderItemView()
    }
}
