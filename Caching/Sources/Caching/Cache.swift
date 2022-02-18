//
//  Cache.swift
//  
//
//  Created by Егор Яковенко on 19.02.2022.
//

import Foundation
import Cache

public class Cache<Key: Hashable, Value: Codable> {
    private let storage: Storage<Key, Value>?

    init(name: String) {
        self.storage = try? Storage(
            diskConfig: DiskConfig(name: name),
            memoryConfig: MemoryConfig(),
            transformer: TransformerFactory.forCodable(ofType: Value.self)
        )
    }

    subscript(key: Key) -> Value? {
        get {
            return try? self.storage?.object(forKey: key)
        }
        set {
            if let value = newValue {
                _ = try? self.storage?.setObject(value, forKey: key)
            } else {
                _ = try? self.storage?.removeObject(forKey: key)
            }
        }
    }
}
