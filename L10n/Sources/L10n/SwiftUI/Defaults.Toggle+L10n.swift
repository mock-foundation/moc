//
//  Defaults.Toggle+L10n.swift
//  
//
//  Created by Егор Яковенко on 03.11.2022.
//

import SwiftUI
import Defaults

public extension Defaults.Toggle<L10nText, Defaults.Key<Bool>> {
    init(l10n: String, key: Key) {
        self.init(key: key) {
            L10nText(l10n)
        }
    }
}
