//
//  AsyncTdFileThumbnail.swift
//  Moc
//
//  Created by Егор Яковенко on 06.07.2022.
//

import SwiftUI

struct AsyncTdFileThumbnail: View {
    let id: Int
    let contentMode: SwiftUI.ContentMode
    
    init(id: Int, contentMode: SwiftUI.ContentMode = .fill) {
        self.id = id
        self.contentMode = contentMode
    }

    var body: some View {
        AsyncTdFile(id: id) { file in
            URL(fileURLWithPath: file.local.path).thumbnail
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } placeholder: {
            Rectangle()
                .skeleton(with: true)
        }
    }
}
