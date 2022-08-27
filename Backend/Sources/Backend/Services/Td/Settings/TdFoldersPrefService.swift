//
//  TdFoldersPrefService.swift
//
//
//  Created by Егор Яковенко on 28.05.2022.
//

import Caching
import TDLibKit
import GRDB
import Combine

public class TdFoldersPrefService: FoldersPrefService {
    private var tdApi: TdApi = .shared
    
    public var updateSubject: PassthroughSubject<Update, Never> {
        tdApi.client.updateSubject
    }

    public init() {}

    public func getFilters() async throws -> [ChatFilterInfo] {
        try! CacheService.shared.getRecords(as: Caching.ChatFilter.self, ordered: [Column("order").asc])
            .map { cached in
                ChatFilterInfo(from: cached)
            }
    }

    public func getFilter(by id: Int) async throws -> TDLibKit.ChatFilter {
        try await tdApi.getChatFilter(chatFilterId: id)
    }

    public func reorderFilters(_ folders: [Int]) async throws {
        _ = try await tdApi.reorderChatFilters(chatFilterIds: folders, mainChatListPosition: 0)
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
