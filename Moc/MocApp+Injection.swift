//
//  MocApp.swift
//  Shared
//
//  Created by Егор Яковенко on 24.12.2021.
//

import SwiftUI
import TDLibKit
import Resolver

@main
struct MocApp: App {
	init() {
		Resolver.register {
			MainViewModel()
		}
		Resolver.register {
			TdApi(client: TdClientImpl())
		}
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
