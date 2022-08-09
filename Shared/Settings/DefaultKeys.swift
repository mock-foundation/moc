//
//  DefaultKeys.swift
//  Moc
//
//  Created by Егор Яковенко on 16.06.2022.
//

import Defaults
import Utilities

extension Defaults.Keys {
    static let folderLayout = Key<FolderLayout>("folderLayout", default: .horizontal)
    static let chatShortcuts = Key<[Int64]>("chatShortcuts", default: [])
    static let showDeveloperInfo = Key<Bool>("showDeveloperInfo", default: false)
//    static let chatInspectorOpenByDefault = Key<Bool>("chatInspectorOpenByDefault", default: true)
}

// Keys that are not managed by the app
extension Defaults.Keys {
    static let sidebarSize = Key<Int>(Constants.sidebarSizeDefaultsKey, default: 0)
}
