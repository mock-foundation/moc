//
//  TextField+L10n.swift
//  
//
//  Created by Егор Яковенко on 03.11.2022.
//

import SwiftUI

public extension TextField<L10nText> {
    init(l10n key: String, prompt: Text? = nil, text: Binding<String>) {
        self.init(text: text, prompt: prompt) { L10nText(key) }
    }
}
