//
//  FolderItemView.swift
//  Moc
//
//  Created by Егор Яковенко on 25.12.2021.
//

import SwiftUI

struct FolderItemView<Icon: View>: View {
    let name: String
    let icon: Icon
    
    @State private var backgroundColor: Color = .clear
    @State private var selected = false
    private let selectedColor = Color("FolderItemSelectedColor")
    
    init(name: String, icon: @autoclosure () -> Icon) {
        self.name = name
        self.icon = icon()
    }

    var body: some View {
        VStack {
            icon
                .font(.system(size: 20))
                .padding(4)
            Text(name)
        }
        .padding(.vertical)
        .frame(width: 80, height: 64)
        .background(selected ? selectedColor : backgroundColor)
        .onHover { isHovered in
            if isHovered {
                backgroundColor = Color("OnHoverColor")
            } else {
                backgroundColor = Color.clear
            }
        }
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        FolderItemView(name: "Name", icon: Image(systemName: "folder"))
    }
}
