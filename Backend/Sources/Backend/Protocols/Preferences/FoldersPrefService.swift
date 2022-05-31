//
//  FoldersPrefService.swift
//  
//
//  Created by Егор Яковенко on 28.05.2022.
//

import TDLibKit

public protocol FoldersPrefService {
    func getFilters() async throws -> [ChatFilterInfo]
    func getFilter(by id: Int) async throws -> ChatFilter
    func reorderFilters(_ folders: [Int]) async throws
    func createFilter(_ filter: ChatFilter) async throws
    func deleteFilter(by id: Int) async throws
    func getRecommended() async throws -> [RecommendedChatFilter]
}
