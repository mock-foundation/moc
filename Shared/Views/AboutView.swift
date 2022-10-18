//
//  AboutView.swift
//  Moc
//
//  Created by Егор Яковенко on 13.07.2022.
//

import SwiftUI
import Utilities

public struct AboutView: View {
    @Environment(\.openURL) private var openURL
    @State private var areAcknowledgmentsOpened = false
    
    public init() { }
    
    var versionString: String {
        SystemUtils.info(key: "CFBundleShortVersionString") as String
    }
    
    var buildNumberString: String {
        SystemUtils.info(key: "CFBundleVersion") as String
    }
    
    var aboutApp: String {
        SystemUtils.info(key: "AboutAppString") as String
    }
    
    var acknowledgments: Acknowledgments {
        let url = Bundle.main.url(forResource: "Acknowledgments", withExtension: "plist")!
//        do {
            let data = try! Data(contentsOf: url)
            let result = try! PropertyListDecoder().decode(Acknowledgments.self, from: data)
            return result
//        } catch {
//            return Acknowledgments(people: [], links: [.init(name: "Failed to parse Acknowledgments.plist", url: URL(string: "https://example.com")!)])
//        }
    }
    
    public var body: some View {
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
                    .foregroundStyle(.secondary)
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
                                Link(
                                    "**Technoblade never dies**",
                                    destination: URL(string: "https://www.curesarcoma.org/technoblade-tribute/")!)
                                Divider()
                                Text("Links").font(.title)
                                ForEach(acknowledgments.links, id: \.self) { link in
                                    Link(link.name, destination: link.actuallyAnURL)
                                }
                                Text("People").font(.title)
                                ForEach(acknowledgments.people, id: \.self) {
                                    $0
                                    // TODO: Make this UI better
                                }
                                
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
                    .background(.ultraThinMaterial)
                    Button {
                        openURL(URL(string: "https://github.com/mock-foundation")!)
                    } label: {
                        Spacer()
                        Text("Our GitHub")
                        Spacer()
                    }
                    .background(.ultraThinMaterial)
                }
                .padding(.trailing)
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
