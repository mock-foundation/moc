//
//  Typealiases.swift
//  
//
//  Created by Егор Яковенко on 28.02.2022.
//

import Foundation
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

/// A typealias to NotificationCenter publisher output type.
public typealias NCPO = NotificationCenter.Publisher.Output

#if os(macOS)
public typealias PlatformImage = NSImage
#elseif os(iOS)
public typealias PlatformImage = UIImage
#endif
