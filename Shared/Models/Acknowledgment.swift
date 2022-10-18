//
//  Acknowledgments.swift
//  Moc
//
//  Created by Егор Яковенко on 15.07.2022.
//

import Foundation

struct Acknowledgments: Codable, Hashable {
    struct Person: Codable, Hashable {
        let name, telegramAt, githubProfile: String
    }
    
    let people: [Person]
    let links: [String: URL]
}
