//
//  Endpoint.swift
//  
//
//  Created by DariaMikots on 06.07.2022.
//

public protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var header: [String: String] { get }
    var body: [String: String] { get }
}
