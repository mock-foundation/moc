//
//  BackportGradient.swift
//  Moc
//
//  Created by Егор Яковенко on 18.06.2022.
//

import SwiftUI

extension Color {
    var backportedGradient: LinearGradient {
        .linearGradient(colors: [self, self.lighter()], startPoint: .bottom, endPoint: .top)
    }
    
    #if os(macOS)
    
    func lighter(by percentage: CGFloat = 30) -> Self {
        Self(NSColor(self).lighter(by: percentage))
    }
    
    func darker(by percentage: CGFloat = 30) -> Self {
        Self(NSColor(self).darker(by: percentage))
    }
    
    #elseif os(iOS)
    
    func lighter(by percentage: CGFloat = 30) -> Self {
        Self(UIColor(self).lighter(by: percentage))
    }
    
    func darker(by percentage: CGFloat = 30) -> Self {
        Self(UIColor(self).darker(by: percentage))
    }
    
    #endif
}
