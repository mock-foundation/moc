//
//  View+SidebarSize.swift
//  Moc
//
//  Created by Егор Яковенко on 15.06.2022.
//

import SwiftUI
import Introspect

extension View {
    @available(iOS 15, *)
    func sidebarSize(_ size: Double) -> some View {
        self.introspectNavigationController { navigationController in
            navigationController.splitViewController?.preferredPrimaryColumnWidthFraction = 1
            navigationController.splitViewController?.maximumPrimaryColumnWidth = size
        }
    }
}
