//
//  AsyncTdImage.swift
//  Moc
//
//  Created by Егор Яковенко on 18.06.2022.
//

import SwiftUI
import TDLibKit
import Utilities
import Logs

struct AsyncTdImage<Content: View, Placeholder: View>: View {
    let id: Int
    let image: (Image) -> Content
    let placeholder: () -> Placeholder
    
    var body: some View {
        AsyncTdFile(id: id) { file in
            image(Image(file: file))
                .transition(.opacity)
                .animation(.easeInOut, value: file)
        } placeholder: {
            placeholder()
        }
    }
}
