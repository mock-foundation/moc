//
//  Mockable.swift
//  
//
//  Created by DariaMikots on 08.07.2022.
//

import Foundation

protocol Mockable {
    func loadJSON<T: Decodable>(filename: String, type: T.Type) -> T
}

extension Mockable {
    func loadJSON<T: Decodable>(filename: String, type: T.Type) -> T {
        guard let path = Bundle.module.path(forResource: filename, ofType: "json")
         else {
            fatalError("Failed to load JSON")
        }
        do {
            let data = try Data(contentsOf: URL(string:path)!)
            let decodedObject = try JSONDecoder().decode(type, from: data)
            return decodedObject
        } catch {
            fatalError("Failed to decode loaded JSON")
        }
    }
}
