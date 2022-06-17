//
//  TabLabelStyle.swift
//  Moc
//
//  Created by Егор Яковенко on 15.06.2022.
//

import SwiftUI

struct TabLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .center, spacing: 8) {
            configuration.icon
                .font(.system(size: 24))
                .frame(height: 24)
            configuration.title
                .font(.footnote)
                .frame(height: 12)
        }
    }
}
