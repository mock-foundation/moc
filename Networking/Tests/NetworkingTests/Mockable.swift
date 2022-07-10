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
                  let json = try! String(contentsOf: Bundle.module.url(
                forResource: filename,
                withExtension: "json"
            )!)
            let data = try! JSONDecoder(
                ).decode(T.self,
                from: json.data(using: .utf8)!
            )
            return data
    }
}
