//
//  MocApp.swift
//  Moc
//
//  Created by Егор Яковенко on 24.12.2021.
//

import SwiftUI
import TDLibKit
import Resolver

extension Resolver {
    public static func registerViewModels() {
        register { MainViewModel() }
    }

    public static func registerTd() {
        register { TdApi(client: TdClientImpl()) }
        register { TdService() }
        NSLog("td registration successful")
    }
}

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
