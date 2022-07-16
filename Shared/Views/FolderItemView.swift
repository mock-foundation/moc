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

private extension SidebarSize {
    var textFont: Font {
        switch self {
            case .small:
                return .system(size: 10)
            case .medium:
                return .body
            case .large:
                return .system(size: 16)
        }
    }
    
    var iconFont: Font {
        switch self {
            case .small:
                return .system(size: 18)
            case .medium:
                return .system(size: 22)
            case .large:
                return .system(size: 26)
        }
    }
    
    var itemWidth: CGFloat {
        switch self {
            case .small:
                return 65
            default:
                return 80
        }
    }
    
    var itemHeight: CGFloat {
        switch self {
            case .small:
                return 45
            case .medium:
                return 64
            case .large:
                return 75
        }
    }
}

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
                Label {
                    Text(name)
                        .lineLimit(1)
                        .fixedSize()
                } icon: {
                    icon
                }
                .font(sidebarSize.textFont)
                
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
            VStack {
                icon.font(sidebarSize.iconFont)
                Text(name).font(sidebarSize.textFont)
            }
            .padding(.vertical, 8)
            .onHover { isHovered in
                if isHovered {
                    backgroundColor = Color("OnHoverColor")
                } else {
                    backgroundColor = Color.clear
                }
            }
            .frame(width: sidebarSize.itemWidth, height: sidebarSize.itemHeight)
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
