//
//  Acknowledgments.swift
//  Moc
//
//  Created by Егор Яковенко on 15.07.2022.
//

import Foundation
import SwiftUI

struct Acknowledgments: Codable, Hashable {
    struct Link: Codable, Hashable {
        let name: String
        let url: String
        
        var actuallyAnURL: URL { URL(string: self.url)! }
    }
    
    struct Person: Codable, Hashable {
        let name, telegramAt, githubProfile: String
    }
    
    let people: [Person]
    let links: [Acknowledgments.Link]
}

extension Acknowledgments.Person: View {
    var body: some View {
        HStack {
            Text(name).fontWeight(.bold)
            Text("•")
            Link("Telegram", destination: URL(string: "https://t.me/\(telegramAt)")!)
            Text("•")
            Link("GitHub", destination: URL(string: "https://github.com/\(githubProfile)")!)
        }
    }
}
