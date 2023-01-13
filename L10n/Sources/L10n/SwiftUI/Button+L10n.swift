//
//  Button+L10n.swift
//  
//
//  Created by Егор Яковенко on 03.11.2022.
//

import SwiftUI

public extension Button<L10nText> {
    init(l10n key: String, action: @escaping () -> Void) {
        self.init(action: action) { L10nText(key) }
    }
    
    init(l10n key: String, role: ButtonRole?, action: @escaping () -> Void) {
        self.init(role: role, action: action) { L10nText(key) }
    }
}
