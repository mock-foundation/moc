//
//  HTTPClient.swift
//  
//
//  Created by DariaMikots on 06.07.2022.
//
import Foundation

public protocol HTTPClient {
    func sendRequest<T: Decodable>(
        endpoint: Endpoint,
        responseModel: T.Type
    ) async throws -> T
}

public extension HTTPClient {
    func sendRequest<T: Decodable>(
        endpoint: Endpoint,
        responseModel: T.Type
    ) async throws -> T {
        guard let url = URL(string: endpoint.baseURL + endpoint.path) else {
            throw RequestError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header
        
         let body = endpoint.body
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else {
                throw RequestError.noResponse
            }
            print("STATUS CODE =>", response.statusCode, "AT =>", request)
            switch response.statusCode {
            case 200...299:
                guard
                    let decodedResponse = try? JSONDecoder().decode(responseModel, from: data)
                else {
                    throw RequestError.decode
                }
                return decodedResponse
            case 403:
                throw RequestError.unauthorized
            default:
                throw RequestError.unexpectedStatusCode
            }
        } catch {
            throw RequestError.unknown
        }
    }
}
