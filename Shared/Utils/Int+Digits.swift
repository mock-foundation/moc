//
//  Int+Digits.swift
//  Moc
//
//  Created by Егор Яковенко on 14.06.2022.
//

import Numerics

public extension Int {
    var digitCount: Int {
        return numberOfDigits(in: self)
    }
    
    private func numberOfDigits(in number: Int) -> Int {
        if number < 10 && number >= 0 || number > -10 && number < 0 {
            return 1
        } else {
            return 1 + numberOfDigits(in: number/10)
        }
    }
}
