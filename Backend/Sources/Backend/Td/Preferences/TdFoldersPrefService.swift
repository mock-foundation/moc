//
//  TdFoldersPrefService.swift
//
//
//  Created by Егор Яковенко on 28.05.2022.
//

import Caching
import TDLibKit

public class TdFoldersPrefService: FoldersPrefService {
    private var tdApi: TdApi = .shared[0]

    public init() {}

    public func getFilters() async throws -> [ChatFilterInfo] {
        try! CacheService.shared.getObjects(as: Caching.ChatFilter.self)
            .map { cached in
                ChatFilterInfo(from: cached)
            }
    }

    public func getFilter(by id: Int) async throws -> TDLibKit.ChatFilter {
        try await tdApi.getChatFilter(chatFilterId: id)
    }

    public func reorderFilters(_ folders: [Int]) async throws {
        _ = try await tdApi.reorderChatFilters(chatFilterIds: folders)
    }

    public func createFilter(_ filter: TDLibKit.ChatFilter) async throws {
        _ = try await tdApi.createChatFilter(filter: filter)
    }

    public func deleteFilter(by id: Int) async throws {
        _ = try await tdApi.deleteChatFilter(chatFilterId: id)
    }

    public func getRecommended() async throws -> [RecommendedChatFilter] {
        try await tdApi.getRecommendedChatFilters().chatFilters
    }
}
