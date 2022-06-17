//
//  MultilineTextField.swift
//  Moc
//
//  Created by Егор Яковенко on 17.06.2022.
//

import SwiftUI

struct MultilineTextField: View {
    @Binding var text: String
    
    var body: some View {
        GeometryReader { geometry in
            NSTextViewWrapper(text: $text, size: geometry.size)
        }
    }
    
}

struct NSTextViewWrapper: NSViewRepresentable {
    typealias Representable = Self
    
    // Hook this binding up with the parent View
    @Binding var text: String
    var size: CGSize
    
    // Get the UndoManager
    @Environment(\.undoManager) var undoManger
    
    // create an NSTextView
    func makeNSView(context: Context) -> NSScrollView {
        
        // create NSTextView inside NSScrollView
        let scrollView = NSTextView.scrollableTextView()
        let nsTextView = scrollView.documentView as! NSTextView
        
        // use SwiftUI Coordinator as the delegate
        nsTextView.delegate = context.coordinator
        
        // set drawsBackground to false (=> clear Background)
        // use .background-modifier later with SwiftUI-View
        nsTextView.drawsBackground = false
        
        // allow undo/redo
        nsTextView.allowsUndo = true
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        // get wrapped nsTextView
        guard let nsTextView = scrollView.documentView as? NSTextView else {
            return
        }
        
        // fill entire given size
        nsTextView.minSize = size
        
        // set NSTextView string from SwiftUI-Binding
        nsTextView.string = text
    }
    
    // Create Coordinator for this View
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Declare nested Coordinator class which conforms to NSTextViewDelegate
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: Representable // store reference to parent
        
        init(_ textEditor: Representable) {
            self.parent = textEditor
        }
        
        // delegate method to retrieve changed text
        func textDidChange(_ notification: Notification) {
            // check that Notification.name is of expected notification
            // cast Notification.object as NSTextView
            
            guard notification.name == NSText.didChangeNotification,
                  let nsTextView = notification.object as? NSTextView else {
                return
            }
            // set SwiftUI-Binding
            parent.text = nsTextView.string
        }
        
        // Pass SwiftUI UndoManager to NSTextView
        func undoManager(for view: NSTextView) -> UndoManager? {
            parent.undoManger
        }
        
        // feel free to implement more delegate methods...
        
    }
    
}
