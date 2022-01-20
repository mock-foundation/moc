//
//  AccountsPrefViewModel.swift
//  Moc
//
//  Created by Егор Яковенко on 20.01.2022.
//

import Foundation
import Resolver
import Backend

class AccountsPrefViewModel: ObservableObject {
    @Injected var dataSource: AccountsPrefDataSource
}
