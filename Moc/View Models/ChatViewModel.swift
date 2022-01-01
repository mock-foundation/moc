//
//  ChatViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 01.01.2022.
//

import Resolver
import Foundation
import TDLibKit

class ChatViewModel: ObservableObject {
    @Injected private var tdApi: TdApi
}
