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
                .font(.system(size: 22))
                .reverseMask(alignment: .topTrailing, {
                    Text("1")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle()
                            .fill(.black))
                        .alignmentGuide(VerticalAlignment.top) { $0[VerticalAlignment.center] }
                        .alignmentGuide(HorizontalAlignment.trailing) { $0[HorizontalAlignment.center] }
                })
                .overlay(
                    Text("1")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle()
                            .fill(.blue)
                            .padding(4)
                        )
                        .alignmentGuide(VerticalAlignment.top) {
                            $0[VerticalAlignment.center]
                        }
                        .alignmentGuide(HorizontalAlignment.trailing) {
                            $0[HorizontalAlignment.center]
                            
                        }, alignment: .topTrailing)
//                .padding(4)
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
        FolderItemView(name: "Name", icon: Image("bot"))
            .preferredColorScheme(.light)
    }
}
