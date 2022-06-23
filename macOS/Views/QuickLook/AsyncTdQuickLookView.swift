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

struct AsyncTdQuickLookView: View {
    let id: Int
    
    var body: some View {
        AsyncTdFile(id: id) { file in
            if #available(macOS 13, iOS 16, *) {
                QuickLookView(url: URL(filePath: file.local.path))
            } else {
                QuickLookView(url: URL(fileURLWithPath: file.local.path))
            }
        } placeholder: {
            EmptyView()
        }
    }
}
