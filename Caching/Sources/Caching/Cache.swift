// Generated using Sourcery 1.7.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all
import Cache
import TDLibKit


// MARK: - BasicGroup
public class BasicGroupCache {
    public typealias Key = Int64
    public typealias Value = BasicGroup
    private let storage: Storage<Key, Value>?

    init() {
        self.storage = try? Storage(
            diskConfig: DiskConfig(name: "BasicGroupCache"),
            memoryConfig: MemoryConfig(),
            transformer: TransformerFactory.forCodable(ofType: Value.self)
        )
    }

    public subscript(key: Key) -> Value? {
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

// MARK: - BasicGroupFullInfo
public class BasicGroupFullInfoCache {
    public typealias Key = Int64
    public typealias Value = BasicGroupFullInfo
    private let storage: Storage<Key, Value>?

    init() {
        self.storage = try? Storage(
            diskConfig: DiskConfig(name: "BasicGroupFullInfoCache"),
            memoryConfig: MemoryConfig(),
            transformer: TransformerFactory.forCodable(ofType: Value.self)
        )
    }

    public subscript(key: Key) -> Value? {
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

// MARK: - Chat
public class ChatCache {
    public typealias Key = Int64
    public typealias Value = Chat
    private let storage: Storage<Key, Value>?

    init() {
        self.storage = try? Storage(
            diskConfig: DiskConfig(name: "ChatCache"),
            memoryConfig: MemoryConfig(),
            transformer: TransformerFactory.forCodable(ofType: Value.self)
        )
    }

    public subscript(key: Key) -> Value? {
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

// MARK: - Supergroup
public class SupergroupCache {
    public typealias Key = Int64
    public typealias Value = Supergroup
    private let storage: Storage<Key, Value>?

    init() {
        self.storage = try? Storage(
            diskConfig: DiskConfig(name: "SupergroupCache"),
            memoryConfig: MemoryConfig(),
            transformer: TransformerFactory.forCodable(ofType: Value.self)
        )
    }

    public subscript(key: Key) -> Value? {
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

// MARK: - SupergroupFullInfo
public class SupergroupFullInfoCache {
    public typealias Key = Int64
    public typealias Value = SupergroupFullInfo
    private let storage: Storage<Key, Value>?

    init() {
        self.storage = try? Storage(
            diskConfig: DiskConfig(name: "SupergroupFullInfoCache"),
            memoryConfig: MemoryConfig(),
            transformer: TransformerFactory.forCodable(ofType: Value.self)
        )
    }

    public subscript(key: Key) -> Value? {
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

// MARK: - User
public class UserCache {
    public typealias Key = Int64
    public typealias Value = User
    private let storage: Storage<Key, Value>?

    init() {
        self.storage = try? Storage(
            diskConfig: DiskConfig(name: "UserCache"),
            memoryConfig: MemoryConfig(),
            transformer: TransformerFactory.forCodable(ofType: Value.self)
        )
    }

    public subscript(key: Key) -> Value? {
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

