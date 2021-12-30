//
//  TdEnvironmentKey.swift
//  Moc
//
//  Created by Егор Яковенко on 24.12.2021.
//

import SwiftUI
import TDLibKit

private struct TdEnvironmentKey: EnvironmentKey {
	static var defaultValue: TdApi = TdApi(client: TdClientImpl())
	
	typealias Value = TdApi
}

extension EnvironmentValues {
	var tdApi: TdApi {
		get { self[TdEnvironmentKey.self] }
		set { self[TdEnvironmentKey.self] = newValue }
	}
}
