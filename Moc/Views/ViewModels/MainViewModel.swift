//
//  MainViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 30.12.2021.
//

import Resolver
import Combine
import TDLibKit

class MainViewModel: ObservableObject {
	@Published var chats: [ChatItem] = []
	
	@Injected private var tdApi: TdApi
	
	func update(chats: [ChatItem]) {
		self.chats = chats
	}
}
