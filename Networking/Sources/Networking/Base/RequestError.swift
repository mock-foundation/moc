//
//  File.swift
//  
//
//  Created by DariaMikots on 06.07.2022.
//

import Foundation
public enum RequestError: Error {
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode
    case unknown

    var customMessage: String {
        switch self {
        case .decode:
            return "Decode error"
        case .unauthorized:
            return "Session expired"
        case .invalidURL:
            return "Something wrong with your url"
        case .noResponse:
            return "Empty response"
        default:
            return "Unknown error"
        }
    }
}
