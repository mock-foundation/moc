//
//  UTType+URL.swift
//  
//
//  Created by Егор Яковенко on 29.06.2022.
//

import UniformTypeIdentifiers

public extension UTType {
    init?(_ url: URL) {
        let fileExtension = url.pathExtension
        self.init(filenameExtension: fileExtension)
    }
}
