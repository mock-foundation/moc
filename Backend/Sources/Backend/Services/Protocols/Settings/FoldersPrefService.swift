//
//  FoldersPrefService.swift
//  
//
//  Created by Егор Яковенко on 28.05.2022.
//

import TDLibKit

public protocol FoldersPrefService: Service {
    func getFilters() async throws -> [ChatFilterInfo]
    func getFilter(by id: Int) async throws -> TDLibKit.ChatFilter
    func reorderFilters(_ folders: [Int]) async throws
    func createFilter(_ filter: TDLibKit.ChatFilter) async throws
    func deleteFilter(by id: Int) async throws
    func getRecommended() async throws -> [RecommendedChatFilter]
}
