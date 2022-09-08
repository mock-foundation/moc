//
//  Service.swift
//  
//
//  Created by Егор Яковенко on 09.07.2022.
//

import TDLibKit
import Combine

/// A base service.
public protocol Service: ObservableObject {
    var updateSubject: PassthroughSubject<Update, Never> { get }
}
