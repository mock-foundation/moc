//
//  AsyncTdQuickLookView.swift
//  Moc
//
//  Created by Егор Яковенко on 20.06.2022.
//

import SwiftUI
import TDLibKit
import Utilities
import Logs
import SkeletonUI

struct AsyncTdQuickLookView: View {
    let id: Int
    
    var body: some View {
        AsyncTdFile(id: id) { file in
            #if os(macOS)
            QuickLookView(url: URL(filePath: file.local.path))
            #elseif os(iOS)
            QuickLookPreviewWrapper(items: .constant([
                QuickLookPreviewItem(url: URL(filePath: file.local.path), title: "")
            ]), index: .constant(0))
            #endif
        } placeholder: {
            Rectangle()
                .skeleton(with: true)
        }
    }
}
