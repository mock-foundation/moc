//
//  Color+Additional.swift
//  Moc
//
//  Created by Егор Яковенко on 30.08.2022.
//

import SwiftUI

extension Color {
    #if os(macOS)
    static let darkGray = Color(nsColor: .darkGray)
    #elseif os(iOS)
    static let darkGray = Color(uiColor: .darkGray)
    #endif
}
