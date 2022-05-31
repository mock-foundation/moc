//
//  FoldersPrefViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 28.05.2022.
//

import Backend
import Combine
import Foundation
import OrderedCollections
import Resolver
import TDLibKit
import Utilities

class FoldersPrefViewModel: ObservableObject {
    @Injected private var service: FoldersPrefService

    @Published var showDeleteConfirmationAlert = false
    @Published var showCreateFolderSheet = false
    @Published var showEditFolderSheet = false
    @Published var createFolderSheetErrorAlertShown = false
    @Published var createFolderSheetErrorAlertText = ""
    @Published var folderIdToEdit = 0
    @Published var createFolderName = ""

    private var subscribers: [AnyCancellable] = []

    init() {
        DispatchQueue.main.async {
            Task {
                self.folders = OrderedSet(try await self.service.getFilters())
            }
        }
        subscribers.append(SystemUtils.ncPublisher(for: .updateChatFilters)
            .sink { notification in
                let update = notification.object as! UpdateChatFilters
                DispatchQueue.main.async {
                    self.folders = OrderedSet(update.chatFilters)
                }
            }
        )
    }

    @Published var folders: OrderedSet<ChatFilterInfo> = []

    func getFolder(by id: Int) async throws -> ChatFilter {
        try await service.getFilter(by: id)
    }

    func createFolder() async throws {
//        try await service.createFilter(filter)
    }
}
