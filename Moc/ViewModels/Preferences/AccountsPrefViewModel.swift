//
//  AccountsPrefViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 20.01.2022.
//

import Foundation
import Backend
import Resolver

class AccountsPrefViewModel: ObservableObject {
    @Injected var dataSource: AccountsPrefService
}
