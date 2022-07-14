//
//  AboutView.swift
//  Moc
//
//  Created by Егор Яковенко on 13.07.2022.
//

import SwiftUI
import Utilities

struct AboutView: View {
    @Environment(\.openURL) private var openURL
    @State private var areAcknowledgmentsOpened = false
    
    var versionString: String {
        SystemUtils.info(key: "CFBundleShortVersionString") as String
    }
    
    var buildNumberString: String {
        SystemUtils.info(key: "CFBundleVersion") as String
    }
    
    var aboutApp: String {
        SystemUtils.info(key: "AboutAppString") as String
    }
    
    var body: some View {
        HStack {
            VStack {
                Image("WelcomeScreenImage")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .padding()
            }
            VStack(alignment: .leading) {
                Text("Moc")
                    .font(.system(size: 40, weight: .medium, design: .default))
                Text("Version \(versionString) (\(buildNumberString))")
                    .foregroundColor(.gray)
                Divider()
                Text(aboutApp)
                Spacer()
                HStack {
                    Button {
                        areAcknowledgmentsOpened = true
                    } label: {
                        Text("Acknowledgments")
                    }
                    .sheet(isPresented: $areAcknowledgmentsOpened) {
                        ScrollView {
                            VStack {
                                Text("Acknowledgments")
                                    .font(.system(size: 40, weight: .medium, design: .default))
                                Divider()
                                Link("AlertToast", destination: URL(string: "https://github.com/elai950/AlertToast")!)
                                Link("Defaults", destination: URL(string: "https://github.com/sindresorhus/Defaults")!)
                            }.padding()
                        }
                        .overlay(alignment: .topTrailing) {
                            Button {
                                areAcknowledgmentsOpened = false
                            } label: {
                                Image(systemName: "xmark")
                                    .padding()
                            }.buttonStyle(.plain)
                        }
                        .frame(width: 450, height: 350)
                    }
                    Button {
                        openURL(URL(string: "https://github.com/mock-foundation")!)
                    } label: {
                        Spacer()
                        Text("Our GitHub")
                        Spacer()
                    }
                }.padding(.trailing)
            }
            .padding(.vertical)
        }
        .frame(width: 550, height: 250)
        .fixedSize()
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
