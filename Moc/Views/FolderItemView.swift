//
//  FolderItemView.swift
//  Moc
//
//  Created by Егор Яковенко on 25.12.2021.
//

import SwiftUI
import Utilities
import Defaults
import Combine

struct FolderItemView<Icon: View>: View {
    let name: String
    let icon: Icon
    let unreadCount: Int
    let horizontal: Bool
    
    @State private var backgroundColor: Color = .clear
    @State private var sidebarSize: SidebarSize = .medium

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
                let label = Label {
                    Text(name)
                        .lineLimit(1)
                        .fixedSize()
                } icon: {
                    icon
                }
                if sidebarSize != .medium {
                    label.font(.system(size: sidebarSize == .small ? 10 : 18))
                } else {
                    label
                }
                if unreadCount != 0 {
                    counter
                        .background(Capsule(style: .continuous)
                            .fill(Color.accentColor)
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
            let stack = VStack {
                if sidebarSize != .medium {
                    icon
                        .font(.system(size: sidebarSize == .small ? 16 : 26))
                    Text(name)
                        .font(.system(size: sidebarSize == .small ? 10 : 18))
                } else {
                    icon
                        .font(.system(size: 22))
                    Text(name)
                }
            }
            .padding(.vertical, 8)
            .onHover { isHovered in
                if isHovered {
                    backgroundColor = Color("OnHoverColor")
                } else {
                    backgroundColor = Color.clear
                }
            }
            
            if sidebarSize != .medium {
                stack.frame(width: sidebarSize == .small ? 65 : 80, height: sidebarSize == .small ? 45 : 75)
            } else {
                stack.frame(width: sidebarSize == .small ? 65 : 80, height: 64)
            }
        }
    }
    
    var body: some View {
        Group {
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
                                    .fill(Color.accentColor)
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
        .onReceive(Defaults.publisher(.sidebarSize)) { value in
            withAnimation(.fastStartSlowStop) {
                sidebarSize = SidebarSize(rawValue: value.newValue) ?? .medium
            }
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
