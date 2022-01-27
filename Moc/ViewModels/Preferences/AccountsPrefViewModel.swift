//
//  AccountsPrefViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 20.01.2022.
//

import Backend
import Foundation
import Resolver

class AccountsPrefViewModel: ObservableObject {
    @Injected var dataSource: AccountsPrefService
}
