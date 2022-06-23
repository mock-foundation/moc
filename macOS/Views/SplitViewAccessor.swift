//
//  SplitViewAccessor.swift
//  Moc
//
//  Created by Егор Яковенко on 23.06.2022.
//  Source: https://github.com/Asperi-Demo/4SwiftUI/blob/master/Answers/Get_sidebar_isCollapsed.md
//

import SwiftUI
import Logs

struct SplitViewAccessor: NSViewRepresentable {
    @Binding var sideCollapsed: Bool
    
    func makeNSView(context: Context) -> some NSView {
        let view = MyView()
        view.sideCollapsed = _sideCollapsed
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
    }
    
    class MyView: NSView {
        var sideCollapsed: Binding<Bool>?
        
        weak private var controller: NSSplitViewController?
        private var observer: Any?
        private var logger = Logger(category: "SplitViewAccessor", label: "UI")
        
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            var sview = self.superview
            
            // find split view through hierarchy
            logger.debug("Searching for NSSplitView")
            while sview != nil, !sview!.isKind(of: NSSplitView.self) {
                logger.debug("Found NSSplitView")
                sview = sview?.superview
            }
            
            guard let sview = sview as? NSSplitView else { return }
            logger.debug("Saved NSSplitView")

            controller = sview.delegate as? NSSplitViewController   // delegate is our controller
            if let sideBar = controller?.splitViewItems.first {     // now observe for state
                observer = sideBar.observe(\.isCollapsed, options: [.new]) { [weak self] _, change in
                    if let value = change.newValue {
                        self?.logger.debug("Updated sideCollapsed to \(!value)")
                        self?.sideCollapsed?.wrappedValue = !value    // << here !!
                    }
                }
            }
        }
    }
}

