//
//  FoldersPrefView.swift
//  Moc
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI
import TDLibKit

private enum FolderManipulationMode {
    case edit
    case create
}

struct FoldersPrefView: View {
    @StateObject private var viewModel = FoldersPrefViewModel()

    @State private var selectedFolders: Set<ChatFilterInfo> = []
    @State private var showDeleteConfirmationAlert = false
    @State private var showCreateFolderSheet = false
    @State private var showEditFolderSheet = false
    
    @State private var folderIdToEdit = 0
    
    @State private var createFolderName = ""
    
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
                TextField("Folder name", text: $createFolderName)
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
                    showCreateFolderSheet = false
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    //                showCreateFolderSheet = false
                } label: {
                    Text(mode == .edit ? "Finish" : "Create folder")
                }
                .buttonStyle(.borderedProminent)
            }
            
        }
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
                List(viewModel.folders) { folder in
                    Label { Text(folder.title) } icon: {
                        Image(tdIcon: folder.iconName)
                    }
                    .font(.title2)
                    .padding(4)
                    .contextMenu {
                        Button {
                            showEditFolderSheet = true
                        } label: {
                            Image(systemName: "pencil")
                            Text("Edit")
                        }
                        Button(role: .destructive) {
                            showDeleteConfirmationAlert = true
                        } label: {
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            showEditFolderSheet = true
                        } label: {
                            Text("Edit")
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            showDeleteConfirmationAlert = true
                        } label: {
                            Text("Delete")
                        }
                        
                    }
                }
                .listStyle(.bordered(alternatesRowBackgrounds: true))
                .frame(minHeight: 150)
                .alert("You sure?", isPresented: $showDeleteConfirmationAlert) {
                    Button(role: .cancel) {
                        
                    } label: {
                        Text("Nope")
                    }
                    Button(role: .destructive) {
                        
                    } label: {
                        Text("I am!")
                    }
                }
                .sheet(isPresented: $showCreateFolderSheet) {
                    makeFolderManipulationView(.create)
                        .frame(width: 500)
                }
                HStack {
                    Spacer()
                    Button {
                        showCreateFolderSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            List {
                Section("Recommended") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Title")
                                .fontWeight(.medium)
                            Text("Description")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button("Add") { }
                    }
                }
                Section("Layout") {
                    Text("To be filled")
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
