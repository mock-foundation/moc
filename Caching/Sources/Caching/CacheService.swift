//
//  CacheService.swift
//  
//
//  Created by Егор Яковенко on 29.05.2022.
//

import Foundation
import GRDB

// MARK: - Definition

public class CacheService {
    public static var shared = CacheService()
    
    let dbQueue = try! DatabaseQueue(path: "cache.sqlite")
    
    var migrator = DatabaseMigrator()
    
    init() {
        #if DEBUG
        // Speed up development by nuking the database when migrations change
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        registerMigrations()
        // Migrate if not already
        if (try! dbQueue.read { db in
            return try! !migrator.hasCompletedMigrations(db)
        }) {
            try! migrator.migrate(dbQueue)
        }
    }
}

// MARK: - Private methods

private extension CacheService {
    private func registerMigrations() {
        migrator.registerMigration("v1") { db in
            try db.create(table: "chatFilter") { t in
                t.column("title", .text).notNull()
                t.column("id", .integer).notNull().unique(onConflict: .replace)
                t.column("iconName", .text).notNull()
            }
        }
    }
    
    private func save<Object>(db: Database, object: Object) throws
    where Object: FetchableRecord, Object: PersistableRecord {
        try object.insert(db)
    }
    
    private func getObjects<Object>(from db: Database, as object: Object.Type) throws -> [Object]
    where Object: FetchableRecord, Object: PersistableRecord {
        return try object.fetchAll(db)
    }
}

// MARK: - Public methods

public extension CacheService {
    func save<Object>(object: Object) where Object: FetchableRecord, Object: PersistableRecord {
        try! dbQueue.write { db in
           try save(db: db, object: object)
        }
    }
    
    func getObjects<Object>(as object: Object.Type) throws -> [Object]
    where Object: FetchableRecord, Object: PersistableRecord {
        return try dbQueue.read { db in
            return try getObjects(from: db, as: object)
        }
    }
}
