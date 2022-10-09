//
//  MenubarAction.swift
//  
//
//  Created by Егор Яковенко on 09.10.2022.
//

import Combine
import SwiftUI

public enum MenubarAction {
    case trigger(MenubarItem)
    case toggle(MenubarItem, Bool)
}
