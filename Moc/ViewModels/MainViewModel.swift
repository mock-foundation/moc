//
//  MainViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 01.01.2022.
//

import Resolver
import SwiftUI
import TDLibKit

class MainViewModel: ObservableObject {
    @Published var chatList: [Chat] = []
}
