//
//  AsyncTdFileThumbnail.swift
//  Moc
//
//  Created by Егор Яковенко on 06.07.2022.
//

import SwiftUI

struct AsyncTdFileThumbnail: View {
    let id: Int

    var body: some View {
        AsyncTdFile(id: id) { file in
            URL(fileURLWithPath: file.local.path).thumbnail
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .skeleton(with: true)
        }
    }
}
