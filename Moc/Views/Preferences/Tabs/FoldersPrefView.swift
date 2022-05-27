//
//  FoldersPrefView.swift
//  Moc
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI

struct FoldersPrefView: View {
    var body: some View {
        HStack {
            VStack {
                Image("MockChatPhoto")
                    .resizable()
                    .frame(width: 50, height: 60)
                Text("Create folders for different groups of chats and quickly switch between them.")
                    .padding()
                    .multilineTextAlignment(.center)
                HStack {
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                    }
                }.padding(.horizontal)
                List {
                    ForEach(0..<10) { index in
                        Label { Text("Folder \(index)") } icon: {
                            Image(tdIcon: "Love")
                        }.padding(4)
                    }
                }.listStyle(.bordered(alternatesRowBackgrounds: true))
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
    }
}
