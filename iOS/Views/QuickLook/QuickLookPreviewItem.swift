//
//  QuickLookPreviewItem.swift
//  Moc
//
//  Created by Егор Яковенко on 21.06.2022.
//

import QuickLook

public class QuickLookPreviewItem: NSObject, QLPreviewItem {
    public var previewItemURL: URL?
    public var previewItemTitle: String?
    
    public init(url: URL, title: String) {
        self.previewItemURL = url
        self.previewItemTitle = title
    }
}
