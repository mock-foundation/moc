//
//  Animation+FastStartSlowStop.swift
//  Moc
//
//  Created by Егор Яковенко on 12.07.2022.
//

import SwiftUI

extension Animation {
    static let fastStartSlowStop: Animation = .timingCurve(0.54, -0.07, 0, 1, duration: 0.7)
}
