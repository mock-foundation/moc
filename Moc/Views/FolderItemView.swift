//
//  FolderItemView.swift
//  Moc
//
//  Created by Егор Яковенко on 25.12.2021.
//

import SwiftUI
import Utilities

struct FolderItemView<Icon: View>: View {
    let name: String
    let icon: Icon
    let unreadCount: Int
    let horizontal: Bool
    
    @State private var backgroundColor: Color = .clear
    private let selectedColor = Color("FolderItemSelectedColor")
    
    init(
        name: String,
        icon: @autoclosure () -> Icon,
        unreadCount: Int = 0,
        horizontal: Bool = false
    ) {
        self.name = name
        self.icon = icon()
        self.unreadCount = unreadCount
        self.horizontal = horizontal
    }
    
    private var counter: some View {
        Text("\(unreadCount)")
            .foregroundColor(.white)
            .padding(8)
    }
    
    @ViewBuilder
    private var content: some View {
        if horizontal {
            HStack {
                Label {
                    Text(name)
                        .lineLimit(1)
                        .fixedSize()
                } icon: {
                    icon
                }
                if unreadCount != 0 {
                    counter
                        .background(Capsule(style: .continuous)
                            .fill(.blue)
                            .padding(4))
                }
            }
            #if os(macOS)
            .frame(height: 32)
            #elseif os(iOS)
            .frame(height: 42)
            #endif
            .padding(.horizontal, 8)
            .onHover { isHovered in
                if isHovered {
                    backgroundColor = Color("OnHoverColor")
                } else {
                    backgroundColor = Color.clear
                }
            }
        } else {
            VStack {
                icon
                    .font(.system(size: 22))
                Text(name)
            }
            .padding(.vertical, 8)
            .frame(width: 80, height: 64)
            .onHover { isHovered in
                if isHovered {
                    backgroundColor = Color("OnHoverColor")
                } else {
                    backgroundColor = Color.clear
                }
            }
        }
    }
    
    var body: some View {
        if unreadCount != 0 {
            if !horizontal {
                content
                    .reverseMask(alignment: .topTrailing) {
                        counter
                            .background(Capsule(style: .continuous)
                                .fill(.black))
                            .vTop()
                            .hTrailing()
                    }
                    .overlay(
                        counter
                            .background(Capsule(style: .continuous)
                                .fill(.blue)
                                .padding(4)
                            ), alignment: .topTrailing)
                    .background(backgroundColor)
            } else {
                content
                    .background(backgroundColor)
            }
        } else {
            content
                .background(backgroundColor)
        }
    }
}

extension View {
    public func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        FolderItemView(name: "Name", icon: Image("bot"), unreadCount: 0)
    }
}
