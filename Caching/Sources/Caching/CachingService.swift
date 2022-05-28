//
//  CachingService.swift
//  
//
//  Created by Егор Яковенко on 29.05.2022.
//

import Foundation
import RealmSwift

public class CachingService {
    public static var shared = CachingService()
    
    var realm = try! Realm(fileURL: URL(string: "cache.realm")!)
    
    func writeObject() {
        
    }
}
