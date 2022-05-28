//
//  FoldersPrefViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 28.05.2022.
//

import Foundation
import Backend
import Resolver
import TDLibKit

class FoldersPrefViewModel: ObservableObject {
    @Injected private var service: FoldersPrefService
    
    init() {
        Task {
            self.folders = try await self.service.getFilters()
        }
    }
    
    @Published var folders: [ChatFilterInfo] = []
    
    func getFolder(by id: Int) async throws -> ChatFilter {
        return try await service.getFilter(by: id)
    }
}
