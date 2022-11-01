//
//  FoldersPrefView.swift
//  Moc
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI
import TDLibKit
import Defaults
import Utilities
import L10n

private enum FolderManipulationMode {
    case edit
    case create
}

struct FoldersPrefView: View {
    @StateObject private var viewModel = FoldersPrefViewModel()
    @State private var selectedFolders = Set<ChatFilterInfo.ID>()
    
    @Default(.folderLayout) var folderLayout
    @Default(.showDeveloperInfo) var showDeveloperInfo

    fileprivate func makeFolderManipulationView(_ mode: FolderManipulationMode) -> some View {
        VStack {
            Image("MockChatPhoto")
                .resizable()
                .frame(width: 80, height: 80)
                .padding()
            Text(mode == .edit ? "Edit folder" : "Create a new folder")
                .font(.largeTitle)
                .fontWeight(.bold)

            Form {
                TextField("Folder name", text: $viewModel.createFolderName)
                    .padding()
                Section("Included chats") {
                    // TODO: implement included chats editor
                    Text("To be implemented")
                }
                Section("Excluded chats") {
                    // TODO: implement excluded chats editor
                    Text("To be implemented")
                }
            }.padding(.bottom)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    viewModel.showCreateFolderSheet = false
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        do {
                            try await viewModel.createFolder()
                            viewModel.showCreateFolderSheet = false
                        } catch {
                            viewModel.createFolderSheetErrorAlertText = (error as! TDLibKit.Error).message
                            viewModel.createFolderSheetErrorAlertShown = true
                        }
                    }
                } label: {
                    Text(mode == .edit ? "Finish" : "Create folder")
                }
                .buttonStyle(.borderedProminent)
                .alert("Error!", isPresented: $viewModel.createFolderSheetErrorAlertShown) {} message: {
                    Text(viewModel.createFolderSheetErrorAlertText)
                }
            }
        }
    }
    
//    private var developerFolderList: some View {
//        Table(viewModel.folders, selection: $selectedFolders) {
//            TableColumn("Icon") { folder in
//                Image(tdIcon: folder.iconName)
//            }
//            .width(min: 20, ideal: 40, max: 70)
//            TableColumn("Title", value: \.title)
//            TableColumn("ID") { folder in
//                Text("\(folder.id)")
//            }
//            .width(40)
//        }
//    }
    
    private var folderList: some View {
        List(viewModel.folders) { folder in
            Label {
                if showDeveloperInfo {
                    Text("\(folder.title) (ID: \(folder.id))")
                        .textSelection(.enabled)
                } else {
                    Text(folder.title)
                }
            } icon: {
                Image(tdIcon: folder.iconName)
            }
            .font(.title2)
            .padding(4)
            .contextMenu {
                Button {
                    viewModel.showEditFolderSheet = true
                } label: {
                    Image(systemName: "pencil")
                    Text("Edit")
                }
                Button(role: .destructive) {
                    viewModel.folderIdToDelete = folder.id
                    viewModel.showDeleteConfirmationAlert = true
                } label: {
                    Image(systemName: "trash")
                    L10nText("Common.Delete")
                }
            }
            .swipeActions(edge: .leading) {
                Button {
                    viewModel.showEditFolderSheet = true
                } label: {
                    Text("Edit")
                }
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    viewModel.folderIdToDelete = folder.id
                    viewModel.showDeleteConfirmationAlert = true
                } label: {
                    Text("Delete")
                }
            }
        }
        .frame(minHeight: 150)
        .alert("You sure?", isPresented: $viewModel.showDeleteConfirmationAlert) {
            Button(role: .cancel) {} label: {
                Text("Nope")
            }
            Button(role: .destructive) {
                Task {
                    try await viewModel.deleteFolder(by: viewModel.folderIdToDelete)
                }
            } label: {
                Text("I am!")
            }
        }
        .sheet(isPresented: $viewModel.showCreateFolderSheet) {
            makeFolderManipulationView(.create)
                .frame(width: 500)
        }
    }
    
    @ViewBuilder
    private var folderLayoutSelection: some View {
        Button {
            folderLayout = .vertical
        } label: {
            Image("VerticalFolderLayout")
                .padding(1)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                    #if os(macOS)
                        .stroke(folderLayout == .vertical
                                ? .blue
                                : Color(nsColor: .lightGray), lineWidth: 2)
                    #elseif os(iOS)
                        .stroke(folderLayout == .vertical
                                ? .blue
                                : Color(uiColor: .lightGray), lineWidth: 2)
                    #endif
                )
        }.buttonStyle(.plain)
        Button {
            folderLayout = .horizontal
        } label: {
            Image("HorizontalFolderLayout")
                .padding(1)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                    #if os(macOS)
                        .stroke(folderLayout == .horizontal
                                ? .blue
                                : Color(nsColor: .lightGray), lineWidth: 2)
                    #elseif os(iOS)
                        .stroke(folderLayout == .horizontal
                                ? .blue
                                : Color(uiColor: .lightGray), lineWidth: 2)
                    #endif
                )
        }.buttonStyle(.plain)
    }

    var body: some View {
        HStack {
            VStack {
                if #available(macOS 13.0, *) {
                    L10nText("ChatListFolderSettings.Title")
                        .font(.largeTitle)
                        .font(.system(.largeTitle, weight: .bold))
                } else {
                    L10nText("ChatListFolderSettings.Title")
                        .font(.largeTitle)
                }
                L10nText("ChatListFolderSettings.Info")
                    .padding([.bottom, .horizontal])
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                folderList
                    #if os(macOS)
                    .listStyle(.bordered(alternatesRowBackgrounds: true))
                    #endif
                HStack {
                    Spacer()
                    Button {
                        viewModel.showCreateFolderSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            List {
                Section {
                    ForEach(viewModel.recommended, id: \.self) { recommendation in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(recommendation.filter.title)
                                    .fontWeight(.bold)
                                Text(recommendation.description)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button {
                                Task {
                                    try await viewModel.createFolder(from: recommendation.filter)
                                }
                            } label: {
                                L10nText("ChatListFolderSettings.AddRecommended")
                            }.padding(2)
                        }
                    }
                } header: {
                    L10nText("ChatListFolderSettings.RecommendedFoldersSection")
                }
                Section {
                    #if os(macOS)
                    HStack(spacing: 16) {
                        Spacer()
                        folderLayoutSelection
                        Spacer()
                    }
                    #elseif os(iOS)
                    VStack(spacing: 16) {
                        folderLayoutSelection
                    }
                    #endif
                    L10nText("ChatListFolderSettings.LayoutSection.Note")
                        .font(.footnote)
                } header: {
                    L10nText("ChatListFolderSettings.LayoutSection")
                }
            }
        }.padding()
    }
}

struct FoldersPrefView_Previews: PreviewProvider {
    static var previews: some View {
        FoldersPrefView()
        FoldersPrefView().makeFolderManipulationView(.create)
        FoldersPrefView().makeFolderManipulationView(.edit)
    }
}
