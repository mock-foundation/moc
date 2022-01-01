//
//  MocApp.swift
//  Moc
//
//  Created by Егор Яковенко on 24.12.2021.
//

import SwiftUI
import TDLibKit
import Resolver

@main
struct MocApp: App {
    init() {
        Resolver.registerViewModels()
        Resolver.registerTd()
    }

    var body: some Scene {
        WindowGroup {
            ContentView().onAppear {
                InitService().initService()
            }
        }
    }
}

// kostil'
private class InitService {
    @Injected private var tdService: TdService
    
    public func initService() {
        tdService.initHandler()
    }
}
