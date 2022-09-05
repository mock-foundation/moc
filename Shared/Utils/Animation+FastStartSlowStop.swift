//
//  Animation+FastStartSlowStop.swift
//  Moc
//
//  Created by Егор Яковенко on 12.07.2022.
//

import SwiftUI

extension Animation {
    static func fastStartSlowStop(_ duration: Double = 0.7) -> Animation {
        .timingCurve(0.54, -0.07, 0, 1, duration: duration)
    }
}
