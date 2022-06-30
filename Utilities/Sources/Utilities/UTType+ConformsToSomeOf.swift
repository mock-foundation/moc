//
//  UTType+ConformsToSomeOf.swift
//  
//
//  Created by Егор Яковенко on 29.06.2022.
//

import UniformTypeIdentifiers

public extension UTType {
    /// Checks if a `UTType` conforms to at least one of the types
    /// listed in `types` parameter.
    /// - Parameter types: The types to check against
    /// - Returns: Comparation result
    func conforms(toAtLeastOneOf types: [UTType]) -> Bool {
        for type in types {
            if type.conforms(to: self) {
                return true
            }
        }
        return false
    }
}
