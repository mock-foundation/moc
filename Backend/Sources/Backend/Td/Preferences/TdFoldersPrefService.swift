//
//  TdFoldersPrefService.swift
//  
//
//  Created by Егор Яковенко on 28.05.2022.
//

import TDLibKit

public class TdFoldersPrefService: FoldersPrefService {
    private var tdApi: TdApi = .shared[0]
    
    public init() { }

    public func getFilters() async throws -> [ChatFilterInfo] {
        // TODO: Implement getFilters()
        return []
    }
    
    public func getFilter(by id: Int) async throws -> ChatFilter {
        return try await tdApi.getChatFilter(chatFilterId: id)
    }
    
    public func reorderFilters(_ folders: [Int]) async throws {
        _ = try await tdApi.reorderChatFilters(chatFilterIds: folders)
    }
    
    public func createFilter(_ filter: ChatFilter) async throws {
        _ = try await tdApi.createChatFilter(filter: filter)
    }
    
    public func deleteFilter(by id: Int) async throws {
        _ = try await tdApi.deleteChatFilter(chatFilterId: id)
    }
    
    public func getRecommended() async throws -> RecommendedChatFilters {
        return try await tdApi.getRecommendedChatFilters()
    }
}
