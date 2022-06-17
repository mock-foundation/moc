//
//  GenerateQRCode.swift
//  Moc
//
//  Created by Егор Яковенко on 14.06.2022.
//

import AppKit

extension NSImage {
    static func generateQRCode(from string: String) -> NSImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return NSImage(cgImage: cgimg, size: NSSize(width: 32, height: 32))
            }
        }
        
        return NSImage(systemSymbolName: "xmark.circle", accessibilityDescription: nil)!
    }
}
