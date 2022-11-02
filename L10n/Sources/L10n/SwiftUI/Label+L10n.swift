//
//  Label+L10n.swift
//  
//
//  Created by Егор Яковенко on 01.11.2022.
//

import SwiftUI

public extension Label<L10nText, Image> {
    init(l10n key: String, systemImage: String) {
        self.init {
            L10nText(key)
        } icon: {
            Image(systemName: systemImage)
        }
    }
}
