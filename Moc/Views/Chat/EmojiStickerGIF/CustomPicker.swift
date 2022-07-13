//
//  CustomPicker.swift
//  Moc
//
//  Created by DariaMikots on 14.07.2022.
//

import SwiftUI

struct CustomPicker: View {
    
   private var options: [String]
   private var color1 = Color.gray
   private var color2 = Color.white
    
    @Binding private var preselectedIndex: Int
   
    init(options: [String],
         preselectedIndex: Binding<Int> ) {
        self.options = options
        self.color1 = Color.gray
        self.color2 = Color.white
       _preselectedIndex = preselectedIndex
    }
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(options.indices, id: \.self) { index in
                Button {
                    preselectedIndex = index
                } label: {
                    Image(systemName: options[index])
                        .foregroundColor(
                            .black
                        )
                        .background(
                            RoundedRectangle(
                                cornerRadius: 7
                            )
                            .fill(
                                preselectedIndex == index ? color2 : color1
                            ))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(
                cornerRadius: 7
            )
            .fill(
               color1
            ))
    }
}

struct CustomPicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomPicker(options: ["smile"], preselectedIndex: .constant(2))
    }
}
