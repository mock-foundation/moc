//
//  FoldersPrefView.swift
//  Moc
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI
import TDLibKit

struct FoldersPrefView: View {
    @State private var selectedFolders: Set<ChatFilterInfo> = []
    @State private var showDeleteConfirmationAlert = false
    @State private var showCreateFolderSheet = false
    
    @State private var createFolderName = ""
    
    fileprivate var createFolder: some View {
        VStack {
            Image("MockChatPhoto")
                .resizable()
                .frame(width: 80, height: 80)
                .padding()
            
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
                    Text("Create folder")
                }
                .buttonStyle(.borderedProminent)
            }
            
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                Image("MockChatPhoto")
                    .resizable()
                    .frame(width: 80, height: 80)
                Text("Create folders for different groups of chats and quickly switch between them.")
                    .padding()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                List(selection: $selectedFolders) {
                    ForEach(0..<10) { index in
                        Label { Text("Folder \(index)") } icon: {
                            Image(tdIcon: "Love")
                        }
                        .padding(4)
                        .swipeActions(edge: .leading) {
                            Button {
                                
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
                    createFolder
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
        FoldersPrefView().createFolder
    }
}
