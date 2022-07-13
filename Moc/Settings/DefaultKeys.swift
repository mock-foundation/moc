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
    
    // Keys that are not managed by the app
    static let sidebarSize = Key<Int>(Constants.sidebarSizeDefaultsKey, default: 0)
}
