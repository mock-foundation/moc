//
//  AccountsPrefView.swift
//  Moc
//
//  Created by Егор Яковенко on 12.01.2022.
//

import SwiftUI
import SwiftUIUtils

struct AccountsPrefView: View {
    var body: some View {
        HStack {
            VStack {
                ZStack {
                    Image("MockChatPhoto")
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 256, height: 256)
                    VStack {
                        Spacer()
                        HStack {
                            VStack {
                                Text("Username")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.title)
                                Text("Phone number")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.title3)
                            }
                            Spacer()
                            Text("@nickname")
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
                        .padding()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                .frame(width: 256, height: 256)
                .padding()
                HStack {
                    Button(action: {

                    }) {
                        Label("Add account", systemImage: "person.badge.plus")
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderless)
                    Spacer()
                    Button(role: .destructive, action: {

                    }) {
                        Label("Leave", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    .foregroundColor(.red)
                    .controlSize(.large)
                    .buttonStyle(.borderless)
                }
                .padding(.horizontal, 24)
                Spacer()
            }
            VStack {
                TextField("Phone number", text: .constant(""))

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct AccountsPrefView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsPrefView()
    }
}
