//
//  PhotoSizeType.swift
//  
//
//  Created by Егор Яковенко on 09.09.2022.
//

import TDLibKit

public enum PhotoSizeType: Int {
    // For info on cases, see https://core.telegram.org/api/files#image-thumbnail-types
    case sBox
    case mBox
    case xBox
    case yBox
    case wBox
    case aCrop
    case bCrop
    case cCrop
    case dCrop
    case iString
    case jOutline
    
    var td: String {
        switch self {
            case .sBox:
                return "s"
            case .mBox:
                return "m"
            case .xBox:
                return "x"
            case .yBox:
                return "y"
            case .wBox:
                return "w"
            case .aCrop:
                return "a"
            case .bCrop:
                return "b"
            case .cCrop:
                return "c"
            case .dCrop:
                return "d"
            case .iString:
                return "i"
            case .jOutline:
                return "j"
        }
    }
}
