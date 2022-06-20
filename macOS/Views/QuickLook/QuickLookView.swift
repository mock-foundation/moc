//
//  QuickLookView.swift
//  Moc
//
//  Created by Егор Яковенко on 20.06.2022.
//

import SwiftUI

struct QuickLookView: View {
    var url: URL
    
    var body: some View {
        QuickLookGenericPreviewWrapper(url: url)
    }
}
