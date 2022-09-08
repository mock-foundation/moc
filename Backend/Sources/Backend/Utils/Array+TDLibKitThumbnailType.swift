//
//  Array+TDLibKitThumbnailType.swift
//  
//
//  Created by Егор Яковенко on 09.09.2022.
//

import TDLibKit

public extension Array where Element == PhotoSize {
    
    /// Searches for a photo with a supplied size type. If not found,
    /// searches for the nearest smaller image.
    /// - Parameter type: Size type of the photo. See https://core.telegram.org/api/files#image-thumbnail-types
    /// - Returns: Found photo, or nil if it can not be found
    func getSize(_ type: PhotoSizeType) -> PhotoSize? {
        let filtered = self.filter { $0.type == type.td }
        
        if filtered.isEmpty {
            if type.rawValue == 0 {
                return nil
            } else {
                return getSize(PhotoSizeType(rawValue: type.rawValue - 1)!)
            }
        } else {
            return filtered[0]
        }
    }
}
