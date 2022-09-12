//
//  Introspect+NSSplitView.swift
//  Moc
//
//  Created by Егор Яковенко on 08.09.2022.
//

import SwiftUI
import Introspect
import Logs

extension View {
    public func isSidebarCollapsed(_ isCollapsed: Binding<Bool>) -> some View {
        return modifier(IsSidebarCollapsed(isCollapsed))
    }
}

struct IsSidebarCollapsed: ViewModifier {
    @Binding var isSidebarCollapsed: Bool
    @State private var observer: Any?
        
    init(_ isSidebarCollapsed: Binding<Bool>) {
        self._isSidebarCollapsed = isSidebarCollapsed
    }
    
    func body(content: Content) -> some View {
        content.inject(AppKitIntrospectionView(
            selector: { introspectionView in
                return Introspect.findAncestor(
                    ofType: NSSplitView.self,
                    from: introspectionView)
            },
            customize: { (splitView: NSSplitView) in
                let controller = splitView.delegate as? NSSplitViewController
                if let sideBar = controller?.splitViewItems.first {
                    observer = sideBar.observe(\.isCollapsed, options: [.new]) { _, change in
                        if let value = change.newValue {
                            self.$isSidebarCollapsed.wrappedValue = !value
                        }
                    }
                }
            }
        ))
    }
}
