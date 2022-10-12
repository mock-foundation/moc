//
//  SendUpdate.swift
//  
//
//  Created by Егор Яковенко on 10.10.2022.
//

import Utilities

func sendUpdate(_ update: MenubarAction) {
    SystemUtils.post(notification: .menubarCommandUpdate, with: update)
}
