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

private enum FolderManipulationMode {
    case edit
    case create
}

struct FoldersPrefView: View {
    @StateObject private var viewModel = FoldersPrefViewModel()

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
                    // TODO: implement included chats editor
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
    
    private var folderList: some View {
        List(viewModel.folders) { folder in
            Label { Text(folder.title) } icon: {
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
                    Text("Delete")
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
        Image("VerticalFolderLayout")
        Image("HorizontalFolderLayout")

    }

    var body: some View {
        HStack {
            VStack {
                Text("Chat folders")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Create folders for different groups of chats and quickly switch between them.")
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
                Section("Recommended") {
                    ForEach(viewModel.recommended, id: \.self) { recommendation in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(recommendation.filter.title)
                                    .fontWeight(.bold)
                                Text(recommendation.description)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button("Add") {
                                Task {
                                    try await viewModel.createFolder(from: recommendation.filter)
                                }
                            }
                        }
                    }
                }
                Section("Layout") {
                    #if os(macOS)
                    HStack {
                        folderLayoutSelection
                    }
                    #elseif os(iOS)
                    VStack {
                        folderLayoutSelection
                    }
                    #endif
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
