//
//  QuickLookPreviewWrapper.swift
//  Moc
//
//  Created by Егор Яковенко on 21.06.2022.
//  Source: https://github.com/tomdai/QuickLookPreview/blob/main/Sources/QuickLookPreview/QuickLookPreview.swift
//

import SwiftUI
import QuickLook

struct QuickLookPreviewWrapper: UIViewControllerRepresentable {
    @Binding var items: [QuickLookPreviewItem]
    @Binding var index: Int
    
    func makeUIViewController(context: Context) -> UIViewController {
        let qlPreviewController = QLPreviewController()
        qlPreviewController.dataSource = context.coordinator
        qlPreviewController.currentPreviewItemIndex = index
        let uiNavigationController = UINavigationController(rootViewController: qlPreviewController)
        return uiNavigationController
    }
    
    func updateUIViewController(_: UIViewController, context _: Context) { }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: QLPreviewControllerDataSource {
        let parent: QuickLookPreviewWrapper
        
        init(parent: QuickLookPreviewWrapper) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(in what: QLPreviewController) -> Int {
            return self.parent.$items.count
        }
        
        func previewController(_: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.items[index]
        }
    }
}
