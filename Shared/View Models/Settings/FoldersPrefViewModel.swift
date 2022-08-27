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
import SwiftUI

class FoldersPrefViewModel: ObservableObject {
    @Injected private var service: any FoldersPrefService

    @Published var showDeleteConfirmationAlert = false
    @Published var showCreateFolderSheet = false
    @Published var showEditFolderSheet = false
    @Published var createFolderSheetErrorAlertShown = false
    @Published var createFolderSheetErrorAlertText = ""
    @Published var folderIdToEdit = 0
    @Published var folderIdToDelete = 0
    @Published var createFolderName = ""
    @Published var createFolderIcon = ""
    
    @Published var folders: [ChatFilterInfo] = []
    @Published var recommended: [RecommendedChatFilter] = []

    private var subscribers: [AnyCancellable] = []
    
    init() {
        DispatchQueue.main.async {
            Task {
                let folders = try await self.service.getFilters()
                let recommended = try await self.service.getRecommended()
                
                withAnimation {
                    self.folders = folders
                    self.recommended = recommended
                }
            }
        }
        service.updateSubject
            .receive(on: RunLoop.main)
            .sink { _ in } receiveValue: { update in
                switch update {
                    case let .chatFilters(info):
                        DispatchQueue.main.async {
                            withAnimation {
                                self.folders = info.chatFilters
                                Task {
                                    self.recommended = try await self.service.getRecommended()
                                }
                            }
                        }
                    default: break
                }
            }
            .store(in: &subscribers)
    }

    func getFolder(by id: Int) async throws -> TDLibKit.ChatFilter {
        try await service.getFilter(by: id)
    }

    func createFolder() async throws {
        try await createFolder(from: TDLibKit.ChatFilter(
            excludeArchived: false,
            excludeMuted: false,
            excludeRead: false,
            excludedChatIds: [],
            iconName: createFolderIcon,
            includeBots: true,
            includeChannels: false,
            includeContacts: false,
            includeGroups: false,
            includeNonContacts: false,
            includedChatIds: [],
            pinnedChatIds: [],
            title: createFolderName
        ))
    }
    
    func createFolder(from filter: TDLibKit.ChatFilter) async throws {
        try await service.createFilter(filter)
    }
    
    func deleteFolder(by id: Int) async throws {
        try await service.deleteFilter(by: id)
    }
}
